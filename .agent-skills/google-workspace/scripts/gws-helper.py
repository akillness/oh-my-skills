#!/usr/bin/env python3
"""
gws-helper.py — Google Workspace AI agent helper
Builds authenticated service clients for all Workspace APIs.

Usage (as a library):
    from gws_helper import GWSClient
    gws = GWSClient()
    doc = gws.docs.documents().create(body={'title': 'Test'}).execute()

Usage (CLI):
    python3 gws-helper.py --check
    python3 gws-helper.py --create-doc "My Document"
    python3 gws-helper.py --list-drive
    python3 gws-helper.py --send-email --to alice@example.com --subject "Hello" --body "World"
"""

import argparse
import base64
import json
import os
import sys
import time
from email.mime.text import MIMEText
from pathlib import Path
from typing import Optional

# ---------------------------------------------------------------------------
# Auth helpers
# ---------------------------------------------------------------------------

TOKEN_DIR = Path(os.environ.get('GWS_TOKEN_DIR', Path.home() / '.config/gws-agent'))

SCOPES = [
    'https://www.googleapis.com/auth/documents',
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/presentations',
    'https://www.googleapis.com/auth/drive',
    'https://www.googleapis.com/auth/gmail.modify',
    'https://www.googleapis.com/auth/calendar',
    'https://www.googleapis.com/auth/chat.messages',
    'https://www.googleapis.com/auth/forms.body',
]


def _load_oauth2_creds():
    try:
        from google.oauth2.credentials import Credentials
        from google.auth.transport.requests import Request
        from google_auth_oauthlib.flow import InstalledAppFlow
    except ImportError:
        raise RuntimeError("Run: pip install google-api-python-client google-auth-oauthlib")

    token_file = TOKEN_DIR / 'token.json'
    creds = None

    if token_file.exists():
        creds = Credentials.from_authorized_user_file(str(token_file), SCOPES)

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            creds_file = TOKEN_DIR / 'credentials.json'
            if not creds_file.exists():
                raise FileNotFoundError(
                    f"credentials.json not found at {creds_file}\n"
                    "Run: bash scripts/auth-setup.sh --oauth2 credentials.json"
                )
            flow = InstalledAppFlow.from_client_secrets_file(str(creds_file), SCOPES)
            creds = flow.run_local_server(port=0)

        token_file.write_text(creds.to_json())

    return creds


def _load_sa_creds(subject: Optional[str] = None):
    try:
        from google.oauth2 import service_account
    except ImportError:
        raise RuntimeError("Run: pip install google-auth")

    sa_file = TOKEN_DIR / 'service-account.json'
    if not sa_file.exists():
        raise FileNotFoundError(
            f"Service account key not found at {sa_file}\n"
            "Run: bash scripts/auth-setup.sh --service-account <key.json>"
        )

    sa_scopes = [
        'https://www.googleapis.com/auth/admin.directory.user',
        'https://www.googleapis.com/auth/admin.directory.group',
        'https://www.googleapis.com/auth/drive',
        'https://www.googleapis.com/auth/documents',
        'https://www.googleapis.com/auth/spreadsheets',
    ]

    creds = service_account.Credentials.from_service_account_file(
        str(sa_file), scopes=sa_scopes
    )

    # Use saved subject if available
    if not subject:
        subj_file = TOKEN_DIR / '.subject'
        if subj_file.exists():
            subject = subj_file.read_text().strip()

    if subject:
        creds = creds.with_subject(subject)

    return creds


def get_credentials(mode: str = 'auto', subject: Optional[str] = None):
    """Return Google credentials. mode: 'oauth2' | 'sa' | 'auto'"""
    if mode == 'sa':
        return _load_sa_creds(subject)
    if mode == 'oauth2':
        return _load_oauth2_creds()
    # auto: try SA first, fall back to OAuth2
    sa_file = TOKEN_DIR / 'service-account.json'
    if sa_file.exists():
        return _load_sa_creds(subject)
    return _load_oauth2_creds()


# ---------------------------------------------------------------------------
# Client builder
# ---------------------------------------------------------------------------

class GWSClient:
    """Authenticated Google Workspace service clients."""

    def __init__(self, auth_mode: str = 'auto', subject: Optional[str] = None):
        try:
            from googleapiclient.discovery import build
        except ImportError:
            raise RuntimeError("Run: pip install google-api-python-client")

        creds = get_credentials(mode=auth_mode, subject=subject)
        self._build = lambda svc, ver: build(svc, ver, credentials=creds)
        self._creds = creds

    @property
    def docs(self):
        return self._build('docs', 'v1')

    @property
    def sheets(self):
        return self._build('sheets', 'v4')

    @property
    def slides(self):
        return self._build('slides', 'v1')

    @property
    def drive(self):
        return self._build('drive', 'v3')

    @property
    def gmail(self):
        return self._build('gmail', 'v1')

    @property
    def calendar(self):
        return self._build('calendar', 'v3')

    @property
    def chat(self):
        return self._build('chat', 'v1')

    @property
    def forms(self):
        return self._build('forms', 'v1')

    @property
    def admin(self):
        return self._build('admin', 'directory_v1')

    @property
    def script(self):
        return self._build('script', 'v1')


# ---------------------------------------------------------------------------
# Utility functions
# ---------------------------------------------------------------------------

def api_call_with_retry(func, *args, max_retries: int = 5, **kwargs):
    """Execute a Google API call with exponential backoff on 429/503."""
    from googleapiclient.errors import HttpError
    for attempt in range(max_retries):
        try:
            return func(*args, **kwargs).execute()
        except HttpError as e:
            if e.resp.status in (429, 503) and attempt < max_retries - 1:
                wait = (2 ** attempt) + 0.1
                print(f"  Rate limit (attempt {attempt+1}/{max_retries}), waiting {wait:.1f}s...")
                time.sleep(wait)
            else:
                raise


def create_doc_from_template(drive, docs, template_id: str, replacements: dict,
                               dest_folder_id: Optional[str] = None) -> str:
    """Clone a template Google Doc and fill placeholders. Returns new doc ID."""
    body = {'name': replacements.get('{{title}}', 'New Document')}
    if dest_folder_id:
        body['parents'] = [dest_folder_id]
    copy = api_call_with_retry(drive.files().copy, fileId=template_id, body=body)
    new_id = copy['id']
    requests = [
        {'replaceAllText': {
            'containsText': {'text': k, 'matchCase': False},
            'replaceText': v
        }}
        for k, v in replacements.items()
    ]
    if requests:
        api_call_with_retry(
            docs.documents().batchUpdate,
            documentId=new_id, body={'requests': requests}
        )
    return new_id


def send_email(gmail, to: str, subject: str, body: str,
               attachments: Optional[list] = None) -> dict:
    """Send a plain text email, optionally with file attachments."""
    from email.mime.multipart import MIMEMultipart
    from email.mime.application import MIMEApplication

    if attachments:
        msg = MIMEMultipart()
        msg['to'] = to
        msg['subject'] = subject
        msg.attach(MIMEText(body))
        for path in attachments:
            path = Path(path)
            with open(path, 'rb') as f:
                part = MIMEApplication(f.read(), Name=path.name)
            part['Content-Disposition'] = f'attachment; filename="{path.name}"'
            msg.attach(part)
    else:
        msg = MIMEText(body)
        msg['to'] = to
        msg['subject'] = subject

    raw = base64.urlsafe_b64encode(msg.as_bytes()).decode()
    return api_call_with_retry(
        gmail.users().messages().send, userId='me', body={'raw': raw}
    )


def append_rows_to_sheet(sheets, spreadsheet_id: str, sheet_name: str, rows: list) -> dict:
    """Append rows to a Google Sheet."""
    return api_call_with_retry(
        sheets.spreadsheets().values().append,
        spreadsheetId=spreadsheet_id,
        range=f'{sheet_name}!A1',
        valueInputOption='USER_ENTERED',
        insertDataOption='INSERT_ROWS',
        body={'values': rows}
    )


def export_doc_to_pdf(drive, doc_id: str, output_path: str) -> str:
    """Export a Google Doc to PDF and save locally."""
    import io
    from googleapiclient.http import MediaIoBaseDownload
    request = drive.files().export_media(fileId=doc_id, mimeType='application/pdf')
    fh = io.BytesIO()
    downloader = MediaIoBaseDownload(fh, request)
    done = False
    while not done:
        _, done = downloader.next_chunk()
    with open(output_path, 'wb') as f:
        f.write(fh.getvalue())
    return output_path


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description='Google Workspace AI agent helper')
    parser.add_argument('--auth-mode', choices=['auto', 'oauth2', 'sa'], default='auto')
    parser.add_argument('--subject', help='Delegation subject email')
    parser.add_argument('--check', action='store_true', help='Check auth and list APIs')

    # Docs
    parser.add_argument('--create-doc', metavar='TITLE', help='Create a new Google Doc')

    # Sheets
    parser.add_argument('--create-sheet', metavar='TITLE', help='Create a new Google Sheet')

    # Drive
    parser.add_argument('--list-drive', action='store_true', help='List recent Drive files')
    parser.add_argument('--create-folder', metavar='NAME', help='Create a Drive folder')
    parser.add_argument('--share', metavar='FILE_ID', help='Share a file (use with --email)')
    parser.add_argument('--email', help='Email address for sharing')

    # Gmail
    parser.add_argument('--send-email', action='store_true', help='Send an email')
    parser.add_argument('--to', help='Recipient email address')
    parser.add_argument('--subject', dest='email_subject', help='Email subject')
    parser.add_argument('--body', help='Email body text')
    parser.add_argument('--attach', nargs='+', help='File paths to attach')

    # Calendar
    parser.add_argument('--list-events', action='store_true', help='List today\'s events')

    args = parser.parse_args()

    if args.check:
        from pathlib import Path
        token_dir = TOKEN_DIR
        print(f"Token dir: {token_dir}")
        print(f"OAuth2 token: {'✅ found' if (token_dir/'token.json').exists() else '❌ missing'}")
        print(f"Service account: {'✅ found' if (token_dir/'service-account.json').exists() else '❌ missing'}")
        return

    gws = GWSClient(auth_mode=args.auth_mode, subject=args.subject)

    if args.create_doc:
        doc = gws.docs.documents().create(body={'title': args.create_doc}).execute()
        print(json.dumps({
            'documentId': doc['documentId'],
            'title': doc.get('title'),
            'url': f"https://docs.google.com/document/d/{doc['documentId']}/edit"
        }, indent=2))

    elif args.create_sheet:
        ss = gws.sheets.spreadsheets().create(body={
            'properties': {'title': args.create_sheet}
        }).execute()
        print(json.dumps({
            'spreadsheetId': ss['spreadsheetId'],
            'title': ss['properties']['title'],
            'url': ss['spreadsheetUrl']
        }, indent=2))

    elif args.list_drive:
        results = gws.drive.files().list(
            pageSize=20,
            fields='files(id, name, mimeType, modifiedTime, webViewLink)',
            orderBy='modifiedTime desc'
        ).execute()
        files = results.get('files', [])
        print(json.dumps(files, indent=2))

    elif args.create_folder:
        folder = gws.drive.files().create(body={
            'name': args.create_folder,
            'mimeType': 'application/vnd.google-apps.folder'
        }, fields='id,name,webViewLink').execute()
        print(json.dumps(folder, indent=2))

    elif args.share and args.email:
        perm = gws.drive.permissions().create(
            fileId=args.share,
            body={'type': 'user', 'role': 'writer', 'emailAddress': args.email},
            sendNotificationEmail=True
        ).execute()
        print(f"✅ Shared {args.share} with {args.email} (permissionId={perm['id']})")

    elif args.send_email:
        if not (args.to and args.email_subject and args.body):
            print("❌ --send-email requires --to, --subject, and --body")
            sys.exit(1)
        send_email(gws.gmail, args.to, args.email_subject, args.body,
                   attachments=args.attach)
        print(f"✅ Email sent to {args.to}")

    elif args.list_events:
        from datetime import datetime, timedelta
        now = datetime.utcnow().isoformat() + 'Z'
        end = (datetime.utcnow() + timedelta(hours=24)).isoformat() + 'Z'
        result = gws.calendar.events().list(
            calendarId='primary',
            timeMin=now, timeMax=end,
            singleEvents=True, orderBy='startTime'
        ).execute()
        events = result.get('items', [])
        for ev in events:
            start = ev.get('start', {})
            dt = start.get('dateTime', start.get('date', '?'))
            print(f"  {dt} — {ev.get('summary', '(no title)')}")

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
