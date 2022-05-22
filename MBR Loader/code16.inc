AnalyzeSectionTable proto stdcall sectionTableAddress: word
SplitCS proto stdcall csAddress: word
SetTimer proto stdcall timerFlagPtr: ptr word
ResetTimer proto stdcall
CHStoLBA proto stdcall head: byte, csAddress: word