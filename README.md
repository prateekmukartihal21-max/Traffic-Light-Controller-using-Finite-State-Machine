# Traffic Light Controller — Moore FSM (Verilog)

A traffic light controller modeled as a **Moore Finite State Machine (FSM)** in Verilog. It handles normal red-yellow-green cycling for two directions (North-South / East-West) and safely inserts a **pedestrian WALK state** on request — without interrupting a light mid-phase.

Verified with a **self-checking testbench** that automatically validates output correctness, timing, and safety.

---

## Overview

- **Design type:** Moore FSM (outputs depend only on current state, never directly on inputs)
- **States:** 5 — `NS_GREEN`, `NS_YELLOW`, `EW_GREEN`, `EW_YELLOW`, `PED_WALK`
- **Pedestrian handling:** A request is latched at any time but only serviced after the current `EW_YELLOW` phase completes, guaranteeing it never cuts a light short
- **Verification:** Self-checking testbench (pass/fail printed automatically, no manual waveform inspection required)

## State Diagram

```
        ┌───────────┐
   ┌───▶│ NS_GREEN  │
   │    └─────┬─────┘
   │          ▼
   │    ┌───────────┐
   │    │ NS_YELLOW │
   │    └─────┬─────┘
   │          ▼
   │    ┌───────────┐
   │    │ EW_GREEN  │
   │    └─────┬─────┘
   │          ▼
   │    ┌───────────┐     ped_req == 1
   │    │ EW_YELLOW │────────────┐
   │    └─────┬─────┘            ▼
   │          │            ┌───────────┐
   │  ped_req == 0         │ PED_WALK  │
   │          │            └─────┬─────┘
   │          ▼                  │
   └──────────┴──────────────────┘
```

## Outputs per State

| State        | NS Light | EW Light | Pedestrian Walk |
|--------------|----------|----------|------------------|
| `NS_GREEN`   | GREEN    | RED      | OFF              |
| `NS_YELLOW`  | YELLOW   | RED      | OFF              |
| `EW_GREEN`   | RED      | GREEN    | OFF              |
| `EW_YELLOW`  | RED      | YELLOW   | OFF              |
| `PED_WALK`   | RED      | RED      | ON               |

## Files

| File | Description |
|------|-------------|
| `design.v` | The Moore FSM traffic light controller module |
| `testbench.v` | Self-checking testbench with timing, safety, and pedestrian-logic checks |

## What the Testbench Checks

1. **Safety** — NS and EW are never both green; the walk signal is never on unless both vehicle directions are red
2. **Output correctness** — light outputs always match the Moore output table for the current state
3. **Timing** — each state holds for its correct number of clock cycles
4. **Pedestrian logic** — a single request results in exactly one WALK phase, inserted at the correct point, with normal cycling resuming afterward

The testbench prints `PASS`/`FAIL` per check and a final verdict:
```
RESULT: ALL TESTS PASSED
```

## How to Run

### Option 1 — EDA Playground (no install required)
1. Go to [edaplayground.com](https://www.edaplayground.com/)
2. Paste `design.v` into the Design pane and `testbench.v` into the Testbench pane
3. Language: **SystemVerilog/Verilog**
4. Simulator: **Icarus Verilog**
5. Click **Run**

### Option 2 — Locally with Icarus Verilog
```bash
iverilog -o sim design.v testbench.v
vvp sim
```

## Tools & Languages

- **HDL:** Verilog
- **Simulator:** Icarus Verilog
- **Platform:** EDA Playground


