# FixTrack Sprint Timeline

## Timeline at a glance

| Date | Event or deadline | Expected outcome |
|---|---|---|
| October 22, 2026 | Sprint 1 Planning and kickoff | Finalize the Sprint 1 Goal, select backlog items, and decompose work into tasks of one day or less |
| November 2, 2026 | Mid-project deliverable | Submit the required mid-project deliverable and review progress against the Product Goal |
| November 11, 2026 | Sprint 1 Review and closeout | Demonstrate the Sprint 1 Increment to the TA or instructor and collect feedback |
| November 12, 2026 | Sprint 1 Retrospective and Sprint 2 Planning | Inspect Sprint 1, finalize improvements, and select Sprint 2 work |
| December 2, 2026 | Sprint 2 Review and feature freeze | Demonstrate the completed MVP Increment and freeze feature work |
| December 3-6, 2026 | Presentation, demo, and release preparation | Rehearse the presentation, stabilize the demo, verify deployment, and finish documentation |
| December 7, 2026 | Final project deadline | Submit the final project and ensure the repository, deployed application, tests, and documentation are complete |

## Sprint schedule

### Sprint 1: Foundation

- **Dates:** October 22-November 11, 2026
- **Sprint Goal:** Establish a secure and usable foundation for FixTrack by implementing authentication, equipment management, problem reporting, and baseline authorization and validation.
- **GitHub milestone:** [Sprint 1 - Foundation](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/milestone/1)
- **Planned backlog:** Foundation stories plus equipment search/open-ticket visibility and the reporter ticket list
- **Planned capacity:** Approximately 20-24 story points, subject to refinement

Sprint 1 should prioritize a demonstrable vertical slice early: a user can
authenticate, a manager can manage equipment, and an authenticated user can
report a valid equipment problem. Authorization and validation should be tested
as part of these features rather than postponed.

### Sprint 2: Workflow and Release

- **Dates:** November 12-December 2, 2026
- **Sprint Goal:** Complete the maintenance workflow from assignment through repair history, then harden, document, test, and deploy the MVP.
- **GitHub milestone:** [Sprint 2 - Workflow and Release](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/milestone/2)
- **Planned backlog:** Technician work queue, manager ticket queue/dispatch, assignment, status, repair records, and history
- **Planned capacity:** Approximately 20-24 story points, subject to refinement
- **Stretch backlog:** Issue #13, preventive maintenance scheduling (5 points), only after the MVP and release work are complete

### Presentation and demo buffer

No new feature work should be planned for December 3-6. This buffer is for
presentation slides, demo data, rehearsal, deployment verification, bug fixes,
documentation, and final submission checks.

### Capacity guidance

Six developers working at an assumed two points per person per week produces
approximately 72 person-week points over two three-week Sprints. That is an
effort estimate, not a reliable Scrum velocity: story points are relative
estimates for the team and should not be multiplied by headcount. Integration,
reviews, testing, coordination, deployment, and the presentation reduce
feature capacity. The team should therefore commit to a refined MVP backlog of
roughly 40-45 story points and use the remaining time for technical tasks,
quality work, and the presentation buffer.

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
| Sprint Planning | October 22 | Sprint Goal, selected GitHub issues, one-day-or-less tasks, and owners |
| Mid-project checkpoint | November 2 | Deliverable submitted; risks and backlog updated |
| Sprint Review | November 11 | Working Increment demonstrated to the TA or instructor; feedback recorded |
| Sprint Retrospective | November 12 | What went well, problems, solutions, and improvement actions |

### Sprint 2

| Event | Date | Required preparation or evidence |
|---|---|---|
| Sprint Planning | November 12 | Sprint Goal, remaining MVP issues, retrospective actions, and one-day-or-less tasks |
| Sprint Review | December 2 | MVP demonstrated to the TA or instructor; feature feedback recorded |
| Sprint Retrospective | December 2 | Final process inspection and release actions |
| Presentation and demo preparation | December 3-6 | Slides, rehearsal, demo data, deployment verification, and final documentation |
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

### By December 2: feature-complete Increment

- [ ] All MVP issues are complete or have an explicitly documented disposition
- [ ] Cucumber and RSpec tests pass
- [ ] Coverage and RuboCop requirements are checked
- [ ] Authorization and invalid-data paths are tested
- [ ] Production deployment is verified
- [ ] Technical documentation, user guide, and architecture documentation are current
- [ ] Sprint 2 Review and Retrospective evidence is recorded

### December 3-6: presentation and demo

- [ ] Presentation slides are complete and reviewed
- [ ] Demo script and seeded demo data are ready
- [ ] The deployed application is verified from a clean user path
- [ ] Team members rehearse assigned presentation sections
- [ ] Only release-blocking fixes are accepted

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
