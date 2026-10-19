## Code and Code Accessories

### User Stories

#### Objectives
User stories are:

1. High-quality, e.g. by SMART or INVEST
1. SMART
1. Specific - details the user, their goal, and the reason for the request, eliminating ambiguity (e.g. "as a `<role>`, so that I can `<goal>`, I want to `<action>`").
2. Measurable - defines clear criteria for success ("definition of done"), such as a feature's functionality or performance.
3. Achievable - the development team can realistically complete it with available resources and within the project's constraints
4. Relevant - the story aligns with the project's overall goals and contributes to improving the user experience.
5. Timebound - includes a defined deadline or timeline.
2. INVEST
1. Independent - can be developed and released without depending on other stories
2. Negotiable - captures the essence of the user's need without being a rigid contract
3. Valuable - delivers value to the end user or customer
4. Estimable - the effort required to complete it can be approximated
5. Small - can be completed within a single Sprint
6. Testable - acceptance criteria can be defined to confirm its completion
2. stored in the team's repository and Project Tracker
3. included in Cucumber feature files
4. numerous, covering both essential and possible features

#### Assessment
User stories will be judged based on whether the team has enough user stories and how consistently a sample of five user stories meets the objectives.

### Acceptance and Unit Tests

#### Objectives

1. Acceptance tests are expressed as Cucumber scenarios
2. Cucumber scenarios are clear, concise, and executable specifications
1. Clear: describes the desired outcome or behavior without detailing the specific steps to accomplish it (understandable to non-technical stakeholders and avoids implementation details)
2. Concise: 3-8 steps
3. Executable: runs without error.  Additionally,
1. Independent: does not rely on the state left by a previous scenario
2. Step definitions are unique and unambiguous
3. Satisfied: is not failing
4. Sound: passes for the right reason (e.g. not because step definitions are empty / do-nothing)
3. Cucumber features contain happy and sad path scenarios
1. Happy: Things work as expected, e.g. user enters valid data or 3rd party service responds with success
2. Sad: Something goes wrong: e.g. user enter invalid data or 3rd party service responds with failure (or fails to respond)
4. Acceptance tests cover at least 90% of the code
5. Unit tests are expressed as RSpec examples
6. Unit tests are FIRST
1. Fast: execute quickly
2. Independent / Isolated: each test is self-contained and not reliant on the outcome or setup of other tests
3. Repeatable: produces the same results every time it is run, regardless of the environment or order of execution
4. Self-reporting / Self-validating: automatically determine their own pass or fail status without requiring manual interpretation
5. Timely: written at or before the time of coding
7. Unit tests cover at least 90% of the code
8. The test suite (acceptance + ... + unit tests) covers at least 90% of the code

#### Assessment
Tests will be judged based on the test execution, coverage, and how consistently a sample of five acceptance tests and five unit tests meets the objectives.

### Comments and Commit Messages

#### Objectives

1. Comments provide context and reasoning, such as explaining why a specific decision was made.
2. Comments explain things which are not obvious from the code.
3. Comments are
1. Informative: specific, actionable, and respectful
2. Relevant: clearly relate to the specific code change (writing code is a change from no code to some code)
3. Maintainable: use of consistent terminology, short and to the point, up-to-date
4. Commit messages provide both a summary of the code changes ("What") and the motivation or reason behind them ("Why")
5. Commit messages have a subject and a body
1. Separate subject from body with a blank line
2. Limit the subject line to 50 characters
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Wrap the body at 72 characters
7. Use the body to explain what and why vs. how
6. Commit messages are:
1. Rational: the message provides a logical explanation for the changes and clearly states the commit type
2. Comprehensive: the message includes a summary of the changes and covers all affected files
3. Concise: the essential information is conveyed succinctly
4. Expressive: the message has grammatical correctness and fluency

#### Assessment
Comments and commit messages will be judged based on how consistently the comments and commit messages in a sample of five code-changing commits meets the objectives.

### Branches and Pull Requests

#### Objectives

- Branch protection ensures that no one is allowed to commit directly to the main branch
- Feature branches are used to develop features and are appropriately named, e.g. `add-user-authentication`
- Pull requests are used to merge completed features into the main branch
- Pull requests are reviewed and approved by another member of the team (e.g. Alice makes changes and creates a pull request, Bob reviews and approves)

#### Assessments
The use of branches and pull requests will be assessed based on a review of the commit log.

### Other Documentation

#### Objectives
The project's GitHub repository has

1. Technical Documentation (required)
1. Detailed instructions for taking the code from zero (fresh fork/clone) to deployed
2. Architectural schemas, e.g. system diagram, class diagram, database diagram
2. User Guide (required)
1. A comprehensive guide on how to use your application, library or software for end-users.
3. Architecture Decision Records (recommended)

1. Captures a single Architectural Decision and its rationale
2. Consists of title, status, context, decision, and consequences, e.g. "In the context of `<use case/user story>`, facing `<concern>` we decided for `<option>` to achieve `<quality>`, accepting `<downside>`."
4. Postmortems (optional, as appropriate)
1. A written record of an incident (e.g. system outage) that describes
1. The incident's impact
2. The actions taken to mitigate or resolve the incident
3. The incident's root cause
4. Follow-up actions taken to prevent the incident from happening again
5. Debug Pointers (optional, as appropriate)
1. Useful information for a developer trying to debug a piece of code, e.g. solutions or workarounds already tried, tries in attempting a fix that did not work
6. Documentation is either in the root `README` or in the `docs/` folder in the project repository on GitHub

#### Assessment
Other documentation will be judged based on what documentation is maintained, whether it is up-to-date, and whether it is accurate.

---

## Scrum Events

### Sprint Planning

#### Objectives
[Refer to Sprint Planning, The 2020 Scrum Guide](https://scrumguides.org/scrum-guide.html#sprint-planning)

1. Sprint Planning initiates the Sprint
2. The Sprint Goal is finalized prior to the end of Sprint Planning
3. Product Backlog items are pulled into the Sprint
4. Product Backlog are decomposed into smaller work items of one day or less

#### Assessment
Sprint Planning will be assessed based on the timely and regular completion of the activity, as evidenced by Git commit logs, Project Tracker activity, and team collaboration/communication platform activity.

### Daily Scrum

#### Objectives
[Refer to Daily Scrum, The 2020 Scrum GuideLinks to an external site.](https://scrumguides.org/scrum-guide.html#daily-scrum)

1. The Daily Scrum is held at the same time and place every working day of the Sprint
2. The Daily Scrum lasts at-most 15 minutes
3. All developers attend the Daily Scrum
4. The Daily Scrum produces an actionable plan for the next day of work

#### Assessment
Daily Scrums will be assessed based on the timely and regular completion of the activity, as evidenced by Git commit logs, Project Tracker activity, and team collaboration/communication platform activity.

### Sprint Review

#### Objectives
[Refer to Sprint Review, The 2020 Scrum GuideLinks to an external site.](https://scrumguides.org/scrum-guide.html#sprint-review)

1. The Sprint Review is the penultimate event of the Sprint
2. The Scrum Team presents their work to key stakeholders
1. The TA and Instructor are key stakeholders, at least one of whom must be at the Sprint Review
3. Progress toward the Product Goal is discussed
4. The Product Backlog is adjusted based on feedback or new opportunities

#### Assessment
Sprint Reviews will be assessed based on the timely and regular completion of the activity, as evidenced by Git commit logs, Project Tracker activity, and team collaboration/communication platform activity.

### Sprint Retrospective

#### Objectives
[Refer to Sprint Retrospective, The 2020 Scrum GuideLinks to an external site.](https://scrumguides.org/scrum-guide.html#sprint-retrospective)

1. The Sprint Retrospective is the last event of the Sprint
2. The Scrum Team inspects how the last Sprint went with regards to individuals, interactions, processes, tools, and their Definition of Done.
3. The Scrum Team discusses what went well during the Sprint, what problems it encountered, and how those problems were (or were not) solved.
4. The Scrum Team identifies the most impactful changes to improve its effectiveness and adds them to the Sprint Backlog for the next Sprint.

#### Assessment
Sprint Retrospectives will be assessed based on the timely and regular completion of the activity, as evidenced by Git commit logs, Project Tracker activity, and team collaboration/communication platform activity.

---

## Scrum Artifacts

### Product Backlog and Burndown

#### Objectives
[Refer to Product Backlog, The 2020 Scrum GuideLinks to an external site.](https://scrumguides.org/scrum-guide.html#product-backlog) 

1. The Product Backlog contains the Product Goal
1. The Product Goal describes a future state of the product which can serve as a target for the Scrum Team to plan against
2. The Product Backlog is an emergent, ordered list of what is needed to improve the product, i.e. what will fulfill the Product Goal
3. Product Backlog items are tracked in the Project Tracker (e.g. GitHub Projects)
4. The Product Backlog is updated during Sprint Planning and Sprint Review
5. The Product Burndown is a chart that shows the number of story points remaining at the end of each working day of the project and is kept up-to-date
1. Burnup (cumulative points completed) is also acceptable

#### Assessment
The Product Backlog and Burndown will be assessed by the timely and regular maintenance of the artifact as evidenced by Git commits and Project Tracker activity.

### Sprint Backlogs and Burndowns

#### Objectives
[Refer to Sprint Backlog, The 2020 Scrum GuideLinks to an external site.](https://scrumguides.org/scrum-guide.html#sprint-backlog)

1. The Sprint Backlog is composed of the Sprint Goal ("why"), the set of Product Backlog items selected for the Sprint ("what"), and an actionable plan for delivering the Increment ("how")
1. The Sprint Goal is the single objective for the Sprint, created during Sprint Planning, and does not change during the Sprint
2. The Sprint Backlog is a highly visible, real-time picture of the work that the Developers plan to accomplish during the Sprint in order to achieve the Sprint Goal
3. Sprint Backlog items are tracked in the Project Tracker (e.g. GitHub Projects)
4. The Sprint Backlog is updated during Sprint Planning and Daily Scrums
5. The Sprint Burndown is a chart that shows the number of story points remaining at the end of each working day of the Sprint and is kept up-to-date
1. Burnup is also acceptable
6. The Scrum Team will conduct at least two Sprints

#### Assessment
The Sprint Backlogs and Burndowns will be assessed by the timely and regular maintenance of the artifact as evidenced by Git commits and Project Tracker activity.

### Increments
An Increment is created when a Product Backlog item meets the Definition of Done.

#### Objectives
[Refer to Increment, The 2020 Scrum GuideLinks to an external site.](https://scrumguides.org/scrum-guide.html#increment)

1. Demonstrated: the sum of the Increments is presented at the Sprint Review
1. Multiple Increments may be created and released within a Sprint
2. Value Delivered: each Increment is usable and provides value to the end-user
3. Quality of Work: all work considered part of an Increment meets the Definition of Done for the Product Backlog item. The Definition of Done must include:
1. Test suite includes acceptance tests with happy and sad paths associated with the item
2. All tests are passing
3. Acceptance test (Cucumber) coverage at least 90%
4. Unit test (RSpec) coverage at least 90%
5. Total Coverage at least 90%
6. Zero Rubocop offenses in Models, Controllers, Helpers, and Tests
7. Deployed to the production environment
4. Velocity: sufficiently many Increments created and each Increment is delivered within the expected timeframe
1. There is no "right" number of Increments for Sprint.
1. It must be at least 1 per Sprint
2. Aim for 1 per Developer per Sprint

#### Assessment
Increments will be assessed based on demonstration, value, quality, and velocity as evidenced by the deployed application, commit logs, tracker activity, and independent verification (i.e. TA clone and test).