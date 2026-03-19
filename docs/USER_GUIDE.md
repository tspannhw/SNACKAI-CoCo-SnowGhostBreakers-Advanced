# SnowGhost Breakers - User Guide

## Introduction

Welcome to SnowGhost Breakers, the premier paranormal investigation management system powered by Snowflake Cortex AI. This guide will help you navigate the application and make the most of its features.

## Getting Started

### Accessing the Application

1. Open your web browser and navigate to the SnowGhost Breakers URL
2. Log in with your Snowflake credentials
3. You'll be directed to the Dashboard

### Navigation

The application has several main sections accessible from the sidebar:

| Section | Purpose |
|---------|---------|
| **Dashboard** | Overview of all paranormal activity |
| **Ghost Registry** | View and manage detected ghosts |
| **Sightings** | Browse and report ghost encounters |
| **Evidence** | Manage collected evidence |
| **Investigations** | Handle investigation cases |
| **Analytics** | Deep-dive into data trends |
| **AI Insights** | AI-powered analysis tools |
| **Map** | Geographic visualization |

---

## Dashboard

The Dashboard provides a real-time overview of paranormal activity.

### Key Metrics

- **Total Ghosts**: Number of registered entities in the system
- **Active Ghosts**: Ghosts currently manifesting
- **Recent Sightings**: Encounters in the last 30 days
- **Open Investigations**: Cases currently being investigated

### Charts

1. **Ghost Type Distribution**: Pie chart showing breakdown by type
2. **Threat Level Distribution**: Bar chart of threat levels
3. **Activity Timeline**: Sighting trends over time
4. **Hotspot Map**: Geographic concentration of activity

### Quick Actions

- Click any chart segment for detailed view
- Use date filters to adjust time range
- Export data using the download button

---

## Ghost Registry

### Viewing Ghosts

The Ghost Registry lists all detected paranormal entities.

#### Filters
- **Type**: Filter by ghost classification (Apparition, Poltergeist, etc.)
- **Threat Level**: Low, Medium, High, Extreme
- **Status**: Active, Dormant, Captured, Neutralized

#### Ghost Cards

Each ghost card displays:
- Name and type
- Threat level (color-coded)
- Status indicator
- Confidence score
- Last sighting date
- Quick action buttons

### Ghost Details

Click a ghost card to view full details:

1. **Overview Tab**
   - Complete description
   - Manifestation pattern
   - First/last sighting dates
   
2. **Sightings Tab**
   - List of all recorded encounters
   - Timeline visualization
   
3. **Evidence Tab**
   - Associated photos, videos, audio
   - AI analysis results
   
4. **AI Report Tab**
   - Generated threat assessment
   - Behavioral analysis
   - Containment recommendations

### AI Report Generation

To generate an AI report for a ghost:

1. Open the ghost's detail page
2. Click "Generate AI Report"
3. Wait for processing (10-30 seconds)
4. Review the comprehensive analysis

The report includes:
- Executive summary
- Threat assessment
- Historical pattern analysis
- Recommended actions
- Safety protocols

---

## Sightings

### Browsing Sightings

The Sightings page displays reported encounters.

#### View Options
- **List View**: Detailed table format
- **Card View**: Visual cards with key info
- **Map View**: Geographic visualization

#### Filters
- Date range
- Location
- Ghost type
- Verification status
- Activity level

### Recording a New Sighting

1. Click "Report Sighting" button
2. Fill in the form:

| Field | Description |
|-------|-------------|
| Ghost (optional) | Select if you know which ghost |
| Location | Where the encounter occurred |
| Coordinates | Lat/long (auto-fills from map) |
| Description | Detailed account of what happened |
| Witness Info | Your name and contact |
| Environmental Data | Temperature, EMF readings |
| Activity Level | 1-10 intensity scale |

3. Click "Submit"
4. AI automatically analyzes the description
5. View your new sighting in the list

### Sighting Verification

Sightings start as "Unverified" and can be verified by admins:

- **Unverified** (yellow): Awaiting review
- **Verified** (green): Confirmed by investigator
- **Disputed** (red): Evidence contradicts report

---

## Evidence Management

### Types of Evidence

| Type | Description |
|------|-------------|
| **Photograph** | Still images of manifestations |
| **Video** | Moving footage |
| **Audio** | EVP recordings, sounds |
| **EMF Recording** | Electromagnetic field data |
| **Thermal Image** | Heat signature captures |
| **Physical** | Tangible artifacts |

### Uploading Evidence

1. Navigate to Evidence section
2. Click "Upload Evidence"
3. Select file(s) from your device
4. Fill in metadata:
   - Associated ghost
   - Capture date/time
   - Description
5. Click "Upload"
6. AI automatically analyzes the content

### AI Evidence Analysis

The system automatically processes evidence:

- **Images**: Object detection, anomaly identification
- **Audio**: Transcription, voice pattern analysis
- **Video**: Frame-by-frame anomaly detection
- **Data**: Pattern analysis, correlation finding

### Similarity Search

Find similar evidence items:

1. Open an evidence item
2. Click "Find Similar"
3. View matched items ranked by similarity
4. Use for pattern identification

---

## Investigations

### Investigation Lifecycle

```
Open → In Progress → Closed
                    ↓
              Archived
```

### Creating an Investigation

1. Click "New Investigation"
2. Enter case details:
   - Case name
   - Description
   - Associated ghosts
   - Lead investigator
   - Team members
   - Priority level
3. Click "Create"

### Managing Investigations

#### Investigation Dashboard

- **Timeline**: Key events and milestones
- **Evidence**: Linked evidence items
- **Sightings**: Related encounters
- **Team**: Assigned investigators
- **Notes**: Investigation notes and findings

#### Updating Status

1. Open investigation
2. Click status dropdown
3. Select new status
4. Add notes (optional)
5. Save

### Closing an Investigation

1. Ensure all evidence is reviewed
2. Document outcome
3. Change status to "Closed"
4. Select outcome:
   - Resolved
   - Unresolved
   - Inconclusive
5. Write final summary

---

## AI Insights

### Chat Interface

Ask questions in natural language:

**Example questions:**
- "What are the most dangerous active ghosts?"
- "Show me sightings near London"
- "When was the Grey Lady last seen?"
- "What's the average EMF reading for poltergeists?"

### Classification Tool

Classify unknown encounters:

1. Enter description of the encounter
2. Click "Classify"
3. View:
   - Predicted ghost type
   - Confidence score
   - Supporting reasoning

### Similarity Search

Find related entities:

1. Enter a description or select existing entity
2. Adjust result count
3. View similar ghosts/sightings
4. Click any result for details

### Report Generation

Generate various reports:

- **Ghost Report**: Comprehensive entity analysis
- **Investigation Summary**: Case overview
- **Hotspot Analysis**: Geographic patterns
- **Threat Assessment**: Risk evaluation

---

## Analytics

### Available Dashboards

1. **Activity Overview**
   - Sighting trends
   - Peak activity times
   - Seasonal patterns

2. **Geographic Analysis**
   - Hotspot map
   - Regional distribution
   - Location clustering

3. **Threat Analysis**
   - Threat level trends
   - High-risk entities
   - Escalation patterns

4. **Investigation Metrics**
   - Case success rates
   - Average resolution time
   - Team performance

### Custom Analysis

Use natural language queries:

1. Go to Analytics > Custom Query
2. Type your question
3. View auto-generated visualization
4. Export or save to dashboard

---

## Map Features

### Viewing the Map

The map shows:
- Ghost sighting locations (pins)
- Hotspot areas (heat overlay)
- Investigation zones

### Map Controls

- **Zoom**: Scroll or use +/- buttons
- **Pan**: Click and drag
- **Layers**: Toggle different data layers
- **Filters**: Show/hide by criteria

### Location Details

Click a map marker to see:
- Location name
- Sighting count
- Ghost types seen
- Latest activity
- Quick link to sightings

---

## Tips and Best Practices

### Recording Quality Sightings

1. **Be Specific**: Include exact times, locations
2. **Describe Fully**: What you saw, heard, felt
3. **Note Conditions**: Weather, lighting, equipment readings
4. **Act Quickly**: Record while details are fresh

### Using AI Effectively

1. **Ask Clear Questions**: Be specific in queries
2. **Review Confidence**: Lower confidence = less certain
3. **Verify Results**: AI is a tool, not final authority
4. **Iterate**: Refine questions based on answers

### Investigation Success

1. **Document Everything**: Photos, notes, readings
2. **Correlate Data**: Link sightings, evidence, patterns
3. **Use AI Analysis**: Generate reports regularly
4. **Collaborate**: Keep team updated via notes

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl/Cmd + K` | Quick search |
| `Ctrl/Cmd + N` | New sighting |
| `Ctrl/Cmd + I` | New investigation |
| `Ctrl/Cmd + /` | Show all shortcuts |
| `Esc` | Close modal/panel |

---

## Troubleshooting

### Common Issues

**"No data found"**
- Check filters aren't too restrictive
- Verify date range includes data
- Refresh the page

**AI analysis taking too long**
- Large files take longer
- Complex queries need more time
- Check server status

**Map not loading**
- Enable location permissions
- Check internet connection
- Try different browser

### Getting Help

- Click the help icon (?) in any section
- Use in-app chat for questions
- Contact support: ghostbusters@snowghostbreakers.com
