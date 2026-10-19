# FixTrack Sprint Timeline

## Timeline at a glance

| Date | Event or deadline | Expected outcome |
|---|---|---|
| October 19-25, 2026 | Kickoff and backlog refinement | Confirm the Definition of Done, refine issues, agree on working agreements, and prepare Sprint 1 |
| October 26, 2026 | Sprint 1 Planning | Finalize the Sprint 1 Goal, select backlog items, and decompose work into tasks of one day or less |
| November 2, 2026 | Mid-project deliverable | Submit the required mid-project deliverable and review progress against the Product Goal |
| November 14, 2026 | Sprint 1 Review | Demonstrate the Sprint 1 Increment to the TA or instructor and collect feedback |
| November 15, 2026 | Sprint 1 Retrospective | Inspect Sprint 1 and record the most important improvements for Sprint 2 |
| November 16, 2026 | Sprint 2 Planning | Finalize the Sprint 2 Goal, select remaining MVP work, and incorporate retrospective actions |
| December 5, 2026 | Sprint 2 Review | Demonstrate the completed MVP Increment to the TA or instructor and confirm release readiness |
| December 6, 2026 | Sprint 2 Retrospective and release hardening | Complete the retrospective, close remaining release tasks, and verify documentation and deployment |
| December 7, 2026 | Final project deadline | Submit the final project and ensure the repository, deployed application, tests, and documentation are complete |

## Sprint schedule

### Sprint 1: Foundation

- **Dates:** October 26-November 15, 2026
- **Sprint Goal:** Establish a secure and usable foundation for FixTrack by implementing authentication, equipment management, problem reporting, and baseline authorization and validation.
- **GitHub milestone:** [Sprint 1 - Foundation](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/milestone/1)
- **Planned backlog:** Issues #4-#8
- **Planned capacity:** 16 story points

Sprint 1 should prioritize a demonstrable vertical slice early: a user can
authenticate, a manager can manage equipment, and an authenticated user can
report a valid equipment problem. Authorization and validation should be tested
as part of these features rather than postponed.

### Sprint 2: Workflow and Release

- **Dates:** November 16-December 6, 2026
- **Sprint Goal:** Complete the maintenance workflow from assignment through repair history, then harden, document, test, and deploy the MVP.
- **GitHub milestone:** [Sprint 2 - Workflow and Release](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/milestone/2)
- **Planned backlog:** Issues #9-#12
- **Planned capacity:** 14 MVP story points
- **Stretch backlog:** Issue #13, preventive maintenance scheduling (5 points), only after the MVP and release work are complete

## Team meeting cadence

The Scrum Guide describes the Daily Scrum as a daily event during the
Sprint. The team currently expects that a full daily meeting will not be
realistic, so the following is the minimum working agreement:

- **Tuesday coordination meeting:** 15 minutes, same time and place each week
- **Thursday coordination meeting:** 15 minutes, same time and place each week
- **Saturday checkpoint:** optional 15-minute meeting during the final week of
  each Sprint, or whenever the team identifies schedule risk
- **Location:** team collaboration platform video call
- **Time:** the team must confirm one recurring time before Sprint 1 Planning

Each coordination meeting will cover:

1. Progress toward the Sprint Goal
2. Work completed since the previous meeting
3. Work planned before the next meeting
4. Blockers, dependencies, and an actionable plan
5. Project Tracker updates, including issue status and estimates

If course assessment requires literal compliance with the Daily Scrum
objective, the team should use a brief asynchronous check-in on the remaining
working days. That check-in should record the same progress, plan, and blocker
information without adding another live meeting.

## Scrum events

### Sprint 1

| Event | Date | Required preparation or evidence |
|---|---|---|
| Sprint Planning | October 26 | Sprint Goal, selected GitHub issues, one-day-or-less tasks, and owners |
| Mid-project checkpoint | November 2 | Deliverable submitted; risks and backlog updated |
| Sprint Review | November 14 | Working Increment demonstrated to the TA or instructor; feedback recorded |
| Sprint Retrospective | November 15 | What went well, problems, solutions, and improvement actions |

### Sprint 2

| Event | Date | Required preparation or evidence |
|---|---|---|
| Sprint Planning | November 16 | Sprint Goal, remaining MVP issues, retrospective actions, and one-day-or-less tasks |
| Sprint Review | December 5 | MVP demonstrated to the TA or instructor; release feedback recorded |
| Sprint Retrospective | December 6 | Final process inspection and follow-up actions |
| Final submission | December 7 | Final repository, deployed application, tests, documentation, and deliverable submitted |

Sprint Reviews are scheduled before the last day of each Sprint so that the
Product Backlog can be adjusted based on stakeholder feedback. Sprint
Retrospectives remain the final Scrum event of each Sprint.

## Deadline and release checklist

### By November 2: mid-project deliverable

- [ ] Required mid-project deliverable is submitted
- [ ] Sprint 1 progress and risks are recorded in the Project Tracker
- [ ] Authentication and the initial equipment/problem-reporting flow are demonstrable
- [ ] Cucumber and RSpec work is tracked for completed or in-progress stories
- [ ] Any scope or dependency changes are discussed at the next coordination meeting

### By December 6: release-ready Increment

- [ ] All MVP issues are complete or have an explicitly documented disposition
- [ ] Cucumber and RSpec tests pass
- [ ] Coverage and RuboCop requirements are checked
- [ ] Authorization and invalid-data paths are tested
- [ ] Production deployment is verified
- [ ] Technical documentation, user guide, and architecture documentation are current
- [ ] Sprint 2 Review and Retrospective evidence is recorded

### December 7: final submission

- [ ] Final project submission is complete
- [ ] Repository contains the final code, tests, and documentation
- [ ] The deployed application is accessible and matches the submitted Increment
- [ ] No stretch feature is allowed to delay MVP completion or submission

## Tracking and evidence

The team will use GitHub Issues and the GitHub Project to record:

- Sprint assignment and issue status
- Story-point estimates and changes
- Task decomposition and ownership
- Blockers and decisions
- Review and retrospective outcomes

Meeting notes should identify attendees, progress, blockers, and the next
action. Git commits, pull requests, Project Tracker activity, and meeting
records provide evidence that the Scrum events and Definition of Done were
followed.

The detailed attendance and meeting record template is maintained in
[Scrum Meeting Log](scrum-meeting-log.md). Do not pre-populate attendance;
complete the log after each meeting.
