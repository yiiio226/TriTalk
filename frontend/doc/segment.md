# 🔊 Shadowing Smart Segmentation & Caching Implementation Spec

## 1. Smart Segmentation Logic (Backend)

We need to intelligently segment the shadowing text based on natural pauses detected by Azure Speech API, rather than fixed word counts.

### 1.1 Segmentation Algorithm

We will process the `Words` list from the Azure Pronunciation Assessment response.

**Rules:**

1.  **Identify Potential Breaks**: Look for words where `Feedback.Prosody.Break.BreakLength` > **300ms** (3000000 units).
2.  **Filter Constraints**:
    - **Minimum Length**: Each segment must contain at least **3 words** (to avoid tiny snippets).
    - **Maximum Segments**: Limit to **5 segments** max per sentence (to avoid fragmentation).
3.  **Merge Strategy**:
    - If a segment is too short (< 3 words), merge it with the preceding or succeeding segment (prefer the side with the shorter pause).
    - If we exceed 5 segments, prioritize the breaks with the largest `BreakLength` and merge the others.
4.  **Fallback**: If no valid breaks are found (e.g., user speaks very fast or text is short), treat the entire text as **1 segment**.

### 1.2 Data Structure Update

Update the `/chat/shadow` endpoint response (`ShadowResult`) to include the calculated segments.

```typescript
// backend/src/types/shadow.ts (or equivalent)

interface SmartSegment {
  text: string; // The text content of this segment
  startIndex: number; // Start word index
  endIndex: number; // End word index
  score: number; // Average pronunciation score for this segment
  hasError: boolean; // If segment contains red/yellow words
}

interface ShadowResult {
  // ... existing fields ...
  segments: SmartSegment[]; // New field
}
```

## 2. Caching Strategy (Frontend)

We will use a **Hybrid Caching Strategy** to maximize reuse and performance.

### 2.1 Cache Key Design

- **Message Cache**: `{messageId}.wav` (For full sentence playback)
- **Segment Cache**: `seg_{hash}.wav` (For individual segment playback)

**Segment Key Formula:**
`Key = "seg_" + SHA256(segmentText + languageCode).substring(0, 16) + ".wav"`

> **Note**: We exclude `voiceName` from the key to simplify cache management, assuming `voiceName` changes are rare or per-language defaults are sufficient for shadowing practice.

### 2.2 Playback Logic

When a user clicks a segment to play:

1.  **Check Segment Cache**: Look for `seg_{hash}.wav`.
    - If exists -> Play immediately.
2.  **Fallback to Stream**:
    - Call `StreamingTtsService` with the segment text.
    - Save result to `seg_{hash}.wav` for next time.

_This decouples segment playback from the full message audio, allowing "Good morning" to be cached once and used across different conversations._

## 3. UI Visualization (Frontend)

Update `ShadowingSheet` to visualize segments clearly.

### 3.1 Visual Design (Segmented Waveform)

Replace the current continuous green line with a **Segmented Pitch Contour**:

```
 [ Segment 1 (92) ]   [ Segment 2 (68) ]   [ Segment 3 (45) ]
 ┌────────────────┐   ┌────────────────┐   ┌────────────────┐
 │    ~~~~🟢~~~~   │   │    ~~~~🟡~~~~   │   │    ~~~~🔴~~~~   │
 └───────┬────────┘   └────────┬───────┘   └───────┬────────┘
         │ Separator           │ Separator         │
```

- **Separators**: Vertical dividers between segments.
- **Color Coding**:
  - 🟢 **Green** (Score ≥ 80)
  - 🟡 **Yellow** (60 ≤ Score < 80)
  - 🔴 **Red** (Score < 60)
- **Interaction**: Tapping a section plays _only_ that segment's audio.

### 3.2 Implementation Details

- **Component**: Create `SegmentedPitchContour` widget.
- **Props**:
  - `segments`: List of `SmartSegment` (includes score, text, duration/word-count ratio).
  - `onSegmentTap(index)`: Callback to play audio.
  - `currentPlayingIndex`: To highlight the active segment.

```dart
// Widget pseudo-code
Row(
  children: segments.map((seg) => Expanded(
    flex: seg.wordCount, // Use word count as proxy for width flux
    child: InkWell(
      onTap: () => playSegment(seg),
      child: Container(
        decoration: borderStyle,
        child: PitchCurve(color: getColor(seg.score)),
      ),
    ),
  )).toList(),
)
```

## 4. Implementation Steps

1.  **Backend**: Update `analyzeShadow` logic to calculate and return `segments` based on Azure `Break` data.
2.  **Frontend Service**: Update `StreamingTtsService` or a helper to generate the new Hash-based cache keys (ignoring voiceName).
3.  **Frontend UI**: Refactor `ShadowingSheet` to use the new `segments` data for the visual waveform and click-to-play interactions.
