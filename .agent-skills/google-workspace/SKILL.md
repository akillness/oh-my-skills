---
name: google-workspace
description: >
  Create, read, update, and manage all Google Workspace documents and services via REST APIs.
  Use when working with Google Docs, Google Sheets, Google Slides, Google Drive, Gmail,
  Google Calendar, Google Chat, Google Forms, Google Meet, Admin SDK, or Apps Script.
  Triggers on: "Google Doc", "Google Sheet", "spreadsheet", "Google Slides", "presentation",
  "Google Drive", "Drive folder", "Gmail", "send email", "Google Calendar", "calendar event",
  "schedule meeting", "Google Chat", "Google Forms", "survey form", "Google Meet",
  "Workspace user", "Apps Script", "구글 문서", "구글 시트", "스프레드시트", "구글 슬라이드",
  "프레젠테이션", "구글 드라이브", "지메일", "이메일 보내기", "구글 캘린더", "일정 추가",
  "회의 예약", "구글 챗", "구글 폼", "설문지", "워크스페이스 사용자".
allowed-tools: Bash Read Write Edit Glob Grep
license: Apache-2.0
compatibility: Requires Python 3.8+, google-api-python-client, google-auth-oauthlib. Node.js 18+ optional for googleapis npm package.
metadata:
  tags: google-workspace, google-docs, google-sheets, google-slides, google-drive, gmail, google-calendar, google-chat, google-forms, admin-sdk, apps-script, automation
  version: "1.0.0"
  author: Agent Skills Team
  platforms: Claude, Gemini, Codex, OpenCode
---

# Google Workspace

Comprehensive AI agent skill for all Google Workspace document operations — Docs, Sheets, Slides, Drive, Gmail, Calendar, Chat, Forms, Admin SDK, and Apps Script — via official REST APIs.

## When to use this skill

- Creating or editing Google Docs, Sheets, Slides
- Uploading, downloading, organizing Google Drive files and folders
- Sending/reading Gmail, managing labels and drafts
- Creating calendar events, inviting attendees, checking availability
- Posting Google Chat messages, managing spaces
- Building and reading Google Forms/surveys
- Provisioning/managing Google Workspace users (Admin SDK)
- Running automated workflows via Apps Script

## Quick Setup

### Step 1: Enable APIs in Google Cloud Console

```bash
# Install gcloud CLI (if not available)
brew install --cask google-cloud-sdk   # macOS
# Or: curl https://sdk.cloud.google.com | bash

# Enable all Workspace APIs
gcloud services enable docs.googleapis.com \
  sheets.googleapis.com slides.googleapis.com \
  drive.googleapis.com gmail.googleapis.com \
  calendar-json.googleapis.com chat.googleapis.com \
  forms.googleapis.com admin.googleapis.com \
  script.googleapis.com
```

### Step 2: Install Python client library

```bash
pip install --upgrade \
  google-api-python-client \
  google-auth-httplib2 \
  google-auth-oauthlib
```

### Step 3: Authenticate

```bash
# OAuth2 — interactive user auth (for accessing user's own data)
bash scripts/auth-setup.sh --oauth2 credentials.json

# Service Account — server-to-server (for automation/backend)
bash scripts/auth-setup.sh --service-account service-account-key.json
```

---

## API Reference by Product

### Google Docs

**Endpoint**: `https://docs.googleapis.com/v1`
**Scope**: `https://www.googleapis.com/auth/documents`

```python
from googleapiclient.discovery import build

docs = build('docs', 'v1', credentials=creds)

# Create document
doc = docs.documents().create(body={'title': 'My Document'}).execute()
doc_id = doc['documentId']

# Read document
doc = docs.documents().get(documentId=doc_id).execute()
content = doc.get('body', {}).get('content', [])

# Edit: replace all text matching a pattern
requests = [{
    'replaceAllText': {
        'containsText': {'text': '{{name}}', 'matchCase': False},
        'replaceText': 'Alice'
    }
}]
docs.documents().batchUpdate(documentId=doc_id, body={'requests': requests}).execute()

# Insert text at position
requests = [{'insertText': {'location': {'index': 1}, 'text': 'Hello!\n'}}]
docs.documents().batchUpdate(documentId=doc_id, body={'requests': requests}).execute()
```

**Key batchUpdate operations**: `insertText`, `deleteContentRange`, `replaceAllText`, `updateTextStyle`, `updateParagraphStyle`, `insertTable`, `insertInlineImage`, `createHeader`, `createFooter`, `createNamedRange`

---

### Google Sheets

**Endpoint**: `https://sheets.googleapis.com/v4`
**Scope**: `https://www.googleapis.com/auth/spreadsheets`

```python
sheets = build('sheets', 'v4', credentials=creds)
ss = sheets.spreadsheets()

# Create spreadsheet
spreadsheet = ss.create(body={
    'properties': {'title': 'My Sheet'},
    'sheets': [{'properties': {'title': 'Data'}}]
}).execute()
sheet_id = spreadsheet['spreadsheetId']

# Write data
ss.values().update(
    spreadsheetId=sheet_id,
    range='Sheet1!A1',
    valueInputOption='USER_ENTERED',
    body={'values': [['Name', 'Score'], ['Alice', 95], ['Bob', 87]]}
).execute()

# Read data
result = ss.values().get(spreadsheetId=sheet_id, range='Sheet1!A:B').execute()
rows = result.get('values', [])

# Append rows
ss.values().append(
    spreadsheetId=sheet_id,
    range='Sheet1!A1',
    valueInputOption='USER_ENTERED',
    body={'values': [['Charlie', 91]]}
).execute()

# Batch update (format: freeze row 1, bold header)
ss.batchUpdate(spreadsheetId=sheet_id, body={'requests': [
    {'updateSheetProperties': {
        'properties': {'sheetId': 0, 'gridProperties': {'frozenRowCount': 1}},
        'fields': 'gridProperties.frozenRowCount'
    }},
    {'repeatCell': {
        'range': {'sheetId': 0, 'startRowIndex': 0, 'endRowIndex': 1},
        'cell': {'userEnteredFormat': {'textFormat': {'bold': True}}},
        'fields': 'userEnteredFormat.textFormat.bold'
    }}
]}).execute()
```

---

### Google Slides

**Endpoint**: `https://slides.googleapis.com/v1`
**Scope**: `https://www.googleapis.com/auth/presentations`

```python
slides = build('slides', 'v1', credentials=creds)

# Create presentation
presentation = slides.presentations().create(
    body={'title': 'My Presentation'}
).execute()
pres_id = presentation['presentationId']

# Read presentation
pres = slides.presentations().get(presentationId=pres_id).execute()
slide_ids = [s['objectId'] for s in pres.get('slides', [])]

# Add a new slide
slides.presentations().batchUpdate(presentationId=pres_id, body={'requests': [
    {'createSlide': {
        'insertionIndex': 1,
        'slideLayoutReference': {'predefinedLayout': 'TITLE_AND_BODY'}
    }}
]}).execute()

# Replace placeholder text
slides.presentations().batchUpdate(presentationId=pres_id, body={'requests': [
    {'replaceAllText': {
        'containsText': {'text': '{{title}}', 'matchCase': False},
        'replaceText': 'Q1 Report'
    }}
]}).execute()

# Get slide thumbnail
page_id = slide_ids[0]
thumb = slides.presentations().pages().getThumbnail(
    presentationId=pres_id,
    pageObjectId=page_id,
    thumbnailProperties_thumbnailSize='LARGE'
).execute()
image_url = thumb['contentUrl']
```

---

### Google Drive

**Endpoint**: `https://www.googleapis.com/drive/v3`
**Scope**: `https://www.googleapis.com/auth/drive`

```python
drive = build('drive', 'v3', credentials=creds)

# Create folder
folder = drive.files().create(body={
    'name': 'My Folder',
    'mimeType': 'application/vnd.google-apps.folder'
}).execute()
folder_id = folder['id']

# Upload file
from googleapiclient.http import MediaFileUpload
media = MediaFileUpload('report.pdf', mimetype='application/pdf')
file = drive.files().create(
    body={'name': 'report.pdf', 'parents': [folder_id]},
    media_body=media,
    fields='id'
).execute()

# Search files
results = drive.files().list(
    q="name contains 'report' and mimeType='application/pdf'",
    fields='files(id, name, modifiedTime)'
).execute()

# Share file
drive.permissions().create(
    fileId=file['id'],
    body={'type': 'user', 'role': 'reader', 'emailAddress': 'alice@example.com'},
    sendNotificationEmail=True
).execute()

# Export Google Doc to PDF
import io
from googleapiclient.http import MediaIoBaseDownload
request = drive.files().export_media(fileId=doc_id, mimeType='application/pdf')
fh = io.BytesIO()
downloader = MediaIoBaseDownload(fh, request)
done = False
while not done:
    _, done = downloader.next_chunk()
with open('document.pdf', 'wb') as f:
    f.write(fh.getvalue())

# Move file
drive.files().update(
    fileId=file['id'],
    addParents=folder_id,
    removeParents='root',
    fields='id, parents'
).execute()

# Copy file (e.g., from template)
copy = drive.files().copy(
    fileId='TEMPLATE_FILE_ID',
    body={'name': 'New Document from Template', 'parents': [folder_id]}
).execute()
```

---

### Gmail

**Endpoint**: `https://gmail.googleapis.com/gmail/v1`
**Scope**: `https://www.googleapis.com/auth/gmail.modify`

```python
import base64
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

gmail = build('gmail', 'v1', credentials=creds)

# Send email
def send_email(to, subject, body):
    msg = MIMEText(body)
    msg['to'] = to
    msg['subject'] = subject
    raw = base64.urlsafe_b64encode(msg.as_bytes()).decode()
    gmail.users().messages().send(userId='me', body={'raw': raw}).execute()

send_email('alice@example.com', 'Hello', 'This is the body.')

# Send with attachment
msg = MIMEMultipart()
msg['to'] = 'alice@example.com'
msg['subject'] = 'Report'
msg.attach(MIMEText('Please find the report attached.'))
with open('report.pdf', 'rb') as f:
    from email.mime.application import MIMEApplication
    part = MIMEApplication(f.read(), Name='report.pdf')
    part['Content-Disposition'] = 'attachment; filename="report.pdf"'
    msg.attach(part)
raw = base64.urlsafe_b64encode(msg.as_bytes()).decode()
gmail.users().messages().send(userId='me', body={'raw': raw}).execute()

# Search emails
results = gmail.users().messages().list(
    userId='me', q='from:boss@company.com subject:urgent is:unread'
).execute()

# Read email
msg_id = results['messages'][0]['id']
msg = gmail.users().messages().get(userId='me', id=msg_id, format='full').execute()
subject = next(h['value'] for h in msg['payload']['headers'] if h['name'] == 'Subject')

# Create label and apply
label = gmail.users().labels().create(
    userId='me', body={'name': 'AI-Processed'}
).execute()
gmail.users().messages().modify(
    userId='me', id=msg_id,
    body={'addLabelIds': [label['id']], 'removeLabelIds': ['UNREAD']}
).execute()

# Create draft
raw_draft = base64.urlsafe_b64encode(MIMEText('Draft body').as_bytes()).decode()
gmail.users().drafts().create(
    userId='me', body={'message': {'raw': raw_draft}}
).execute()

# Set vacation responder
gmail.users().settings().updateVacation(
    userId='me',
    body={
        'enableAutoReply': True,
        'responseSubject': 'Out of Office',
        'responseBodyPlainText': 'I am OOO until Monday.',
        'startTime': '1704067200000',  # Unix ms
        'endTime':   '1704326400000'
    }
).execute()
```

---

### Google Calendar

**Endpoint**: `https://www.googleapis.com/calendar/v3`
**Scope**: `https://www.googleapis.com/auth/calendar`

```python
from datetime import datetime, timedelta
import pytz

calendar = build('calendar', 'v3', credentials=creds)

# Create event
event = calendar.events().insert(
    calendarId='primary',
    body={
        'summary': 'Team Standup',
        'description': 'Daily sync',
        'start': {'dateTime': '2026-03-15T09:00:00+09:00', 'timeZone': 'Asia/Seoul'},
        'end':   {'dateTime': '2026-03-15T09:30:00+09:00', 'timeZone': 'Asia/Seoul'},
        'attendees': [
            {'email': 'alice@example.com'},
            {'email': 'bob@example.com'},
        ],
        'conferenceData': {
            'createRequest': {'requestId': 'meeting-001', 'conferenceSolutionKey': {'type': 'hangoutsMeet'}}
        },
        'recurrence': ['RRULE:FREQ=DAILY;BYDAY=MO,TU,WE,TH,FR']
    },
    conferenceDataVersion=1
).execute()
meet_link = event.get('hangoutLink')

# List today's events
now = datetime.utcnow().isoformat() + 'Z'
end_of_day = (datetime.utcnow() + timedelta(hours=24)).isoformat() + 'Z'
events_result = calendar.events().list(
    calendarId='primary',
    timeMin=now, timeMax=end_of_day,
    singleEvents=True, orderBy='startTime'
).execute()
events = events_result.get('items', [])

# Check free/busy
body = {
    'timeMin': now,
    'timeMax': end_of_day,
    'items': [{'id': 'alice@example.com'}, {'id': 'bob@example.com'}]
}
freebusy = calendar.freebusy().query(body=body).execute()

# Block time / set OOO
calendar.events().insert(
    calendarId='primary',
    body={
        'summary': 'Out of Office',
        'eventType': 'outOfOffice',
        'start': {'date': '2026-03-20'},
        'end':   {'date': '2026-03-22'}
    }
).execute()

# Share calendar
calendar.acl().insert(
    calendarId='primary',
    body={'role': 'reader', 'scope': {'type': 'user', 'value': 'alice@example.com'}}
).execute()
```

---

### Google Chat

**Endpoint**: `https://chat.googleapis.com/v1`
**Scope**: `https://www.googleapis.com/auth/chat.messages`

```python
chat = build('chat', 'v1', credentials=creds)

# Send message to a space
space_name = 'spaces/SPACE_ID'  # From Chat URL
chat.spaces().messages().create(
    parent=space_name,
    body={
        'text': 'Hello from AI agent! 🤖',
        'cards_v2': [{
            'cardId': 'card1',
            'card': {
                'header': {'title': 'Update', 'subtitle': 'Automated report'},
                'sections': [{'widgets': [{'textParagraph': {'text': 'Task completed.'}}]}]
            }
        }]
    }
).execute()

# Create a new space
space = chat.spaces().create(
    body={
        'spaceType': 'SPACE',
        'displayName': 'Project Alpha'
    }
).execute()

# List spaces
spaces = chat.spaces().list().execute()

# Add member to space
chat.spaces().members().create(
    parent=space['name'],
    body={'member': {'name': 'users/alice@example.com', 'type': 'HUMAN'}}
).execute()

# Find or create direct message
dm = chat.spaces().findDirectMessage(name='users/alice@example.com').execute()
```

---

### Google Forms

**Endpoint**: `https://forms.googleapis.com/v1`
**Scope**: `https://www.googleapis.com/auth/forms.body`

```python
forms = build('forms', 'v1', credentials=creds)

# Create form
form = forms.forms().create(body={
    'info': {'title': 'Customer Feedback Survey', 'documentTitle': 'Customer Feedback'}
}).execute()
form_id = form['formId']

# Add questions
forms.forms().batchUpdate(formId=form_id, body={'requests': [
    {
        'createItem': {
            'item': {
                'title': 'How satisfied are you?',
                'questionItem': {
                    'question': {
                        'required': True,
                        'scaleQuestion': {
                            'low': 1, 'high': 5,
                            'lowLabel': 'Not satisfied', 'highLabel': 'Very satisfied'
                        }
                    }
                }
            },
            'location': {'index': 0}
        }
    },
    {
        'createItem': {
            'item': {
                'title': 'Any comments?',
                'questionItem': {
                    'question': {
                        'required': False,
                        'textQuestion': {'paragraph': True}
                    }
                }
            },
            'location': {'index': 1}
        }
    }
]}).execute()

# Get form responses
responses = forms.forms().responses().list(formId=form_id).execute()
for r in responses.get('responses', []):
    for qid, ans in r.get('answers', {}).items():
        print(qid, ans.get('textAnswers', {}).get('answers', []))
```

---

### Admin SDK — Directory API

**Endpoint**: `https://admin.googleapis.com`
**Scope**: `https://www.googleapis.com/auth/admin.directory.user`
**Requires**: Service account with domain-wide delegation

```python
from google.oauth2 import service_account

SA_FILE = 'service-account.json'
SCOPES  = ['https://www.googleapis.com/auth/admin.directory.user',
           'https://www.googleapis.com/auth/admin.directory.group']
creds = service_account.Credentials.from_service_account_file(
    SA_FILE, scopes=SCOPES
).with_subject('admin@yourdomain.com')

admin = build('admin', 'directory_v1', credentials=creds)

# Create user
admin.users().insert(body={
    'primaryEmail': 'newuser@yourdomain.com',
    'name': {'givenName': 'New', 'familyName': 'User'},
    'password': 'TemporaryPassword123!',
    'changePasswordAtNextLogin': True
}).execute()

# List users
users_result = admin.users().list(domain='yourdomain.com', maxResults=100).execute()
for user in users_result.get('users', []):
    print(user['primaryEmail'], user.get('suspended', False))

# Suspend user
admin.users().update(
    userKey='user@yourdomain.com',
    body={'suspended': True}
).execute()

# Add user to group
admin.members().insert(
    groupKey='team@yourdomain.com',
    body={'email': 'user@yourdomain.com', 'role': 'MEMBER'}
).execute()

# List groups
groups = admin.groups().list(domain='yourdomain.com').execute()
```

---

### Apps Script API

**Endpoint**: `https://script.googleapis.com/v1`
**Scope**: `https://www.googleapis.com/auth/script.projects`

```python
script = build('script', 'v1', credentials=creds)

# Run a deployed function
response = script.scripts().run(
    scriptId='DEPLOYED_SCRIPT_ID',
    body={
        'function': 'myFunction',
        'parameters': ['arg1', 42]
    }
).execute()
result = response.get('response', {}).get('result')
```

---

## Common Automation Patterns

### Pattern 1: Create Document from Template

```python
def create_doc_from_template(drive, docs, template_id, replacements, dest_folder_id=None):
    """Clone a template Google Doc and fill in placeholders."""
    body = {'name': replacements.get('{{title}}', 'New Document')}
    if dest_folder_id:
        body['parents'] = [dest_folder_id]
    copy = drive.files().copy(fileId=template_id, body=body).execute()
    new_id = copy['id']
    requests = [
        {'replaceAllText': {'containsText': {'text': k, 'matchCase': False}, 'replaceText': v}}
        for k, v in replacements.items()
    ]
    if requests:
        docs.documents().batchUpdate(documentId=new_id, body={'requests': requests}).execute()
    return new_id
```

### Pattern 2: Bulk Append to Spreadsheet

```python
def bulk_append_rows(sheets, spreadsheet_id, sheet_name, rows):
    """Append multiple rows to a sheet in one API call."""
    sheets.spreadsheets().values().append(
        spreadsheetId=spreadsheet_id,
        range=f'{sheet_name}!A1',
        valueInputOption='USER_ENTERED',
        insertDataOption='INSERT_ROWS',
        body={'values': rows}
    ).execute()
```

### Pattern 3: Create Meeting Notes Document

```python
def create_meeting_notes(calendar, drive, docs, event_id):
    """Create a Google Doc for meeting notes and share with attendees."""
    event = calendar.events().get(calendarId='primary', eventId=event_id).execute()
    attendees = [a['email'] for a in event.get('attendees', [])]
    title = f"Meeting Notes: {event['summary']} — {event['start'].get('dateTime', event['start'].get('date'))}"
    doc = docs.documents().create(body={'title': title}).execute()
    doc_id = doc['documentId']
    for email in attendees:
        drive.permissions().create(
            fileId=doc_id,
            body={'type': 'user', 'role': 'writer', 'emailAddress': email},
            sendNotificationEmail=True
        ).execute()
    return doc_id
```

### Pattern 4: Form Response to Sheet

```python
def sync_form_to_sheet(forms, sheets, form_id, spreadsheet_id):
    """Sync all form responses to a Google Sheet."""
    responses = forms.forms().responses().list(formId=form_id).execute()
    form_data = forms.forms().get(formId=form_id).execute()
    questions = {
        item['itemId']: item.get('title', '')
        for item in form_data.get('items', [])
        if 'questionItem' in item
    }
    headers = ['Timestamp'] + list(questions.values())
    rows = [headers]
    for resp in responses.get('responses', []):
        row = [resp.get('createTime', '')]
        for qid in questions:
            ans = resp.get('answers', {}).get(qid, {})
            text_ans = ans.get('textAnswers', {}).get('answers', [{}])
            row.append(text_ans[0].get('value', '') if text_ans else '')
        rows.append(row)
    sheets.spreadsheets().values().update(
        spreadsheetId=spreadsheet_id,
        range='Sheet1!A1',
        valueInputOption='USER_ENTERED',
        body={'values': rows}
    ).execute()
```

---

## Rate Limits & Best Practices

| API | Quota | Retry Strategy |
|-----|-------|---------------|
| Docs API | 300 req/min/user | Exponential backoff on 429 |
| Sheets API | 300 req/min | Batch operations reduce quota usage |
| Drive API | 1,000 req/100 sec | Use `fields` param to reduce payload |
| Gmail API | 250 quota units/user/sec | `batchModify` for bulk operations |
| Calendar API | 1,000,000 req/day | Use `timeMin`/`timeMax` to limit list results |
| Admin SDK | 10 user creates/domain/sec | Add `time.sleep(0.15)` between creates |

```python
import time
from googleapiclient.errors import HttpError

def api_call_with_retry(func, *args, max_retries=5, **kwargs):
    """Wrapper that retries on 429/503 with exponential backoff."""
    for attempt in range(max_retries):
        try:
            return func(*args, **kwargs).execute()
        except HttpError as e:
            if e.resp.status in (429, 503) and attempt < max_retries - 1:
                wait = (2 ** attempt) + 0.1
                print(f"Rate limit hit, waiting {wait:.1f}s...")
                time.sleep(wait)
            else:
                raise
```

---

## Scopes Reference

| Product | Read Scope | Write Scope |
|---------|-----------|-------------|
| Docs | `auth/documents.readonly` | `auth/documents` |
| Sheets | `auth/spreadsheets.readonly` | `auth/spreadsheets` |
| Slides | `auth/presentations.readonly` | `auth/presentations` |
| Drive | `auth/drive.readonly` | `auth/drive` |
| Gmail | `auth/gmail.readonly` | `auth/gmail.modify` |
| Calendar | `auth/calendar.readonly` | `auth/calendar` |
| Chat | `auth/chat.messages.readonly` | `auth/chat.messages` |
| Forms | `auth/forms.body.readonly` | `auth/forms.body` |
| Admin SDK | `auth/admin.directory.user.readonly` | `auth/admin.directory.user` |

---

## References

- [Google Workspace Developer Hub](https://developers.google.com/workspace)
- [Google Docs API Reference](https://developers.google.com/docs/api/reference/rest)
- [Google Sheets API Reference](https://developers.google.com/sheets/api/reference/rest)
- [Google Slides API Reference](https://developers.google.com/slides/api/reference/rest)
- [Google Drive API v3 Reference](https://developers.google.com/drive/api/reference/rest/v3)
- [Gmail API Reference](https://developers.google.com/gmail/api/reference/rest)
- [Google Calendar API Reference](https://developers.google.com/workspace/calendar/api/guides/overview)
- [Google Chat API Reference](https://developers.google.com/workspace/chat/api/reference/rest)
- [Google Forms API Reference](https://developers.google.com/forms/api/reference/rest)
- [Admin SDK Directory API Reference](https://developers.google.com/workspace/admin/directory/reference/rest)
- [Apps Script REST API](https://developers.google.com/apps-script/guides/rest/api)
- [Auth Overview & Credentials Setup](https://developers.google.com/workspace/guides/auth-overview)
- [Enable APIs Guide](https://developers.google.com/workspace/guides/enable-apis)
