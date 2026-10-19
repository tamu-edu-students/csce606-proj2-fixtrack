FixTrack: Equipment Maintenance and Repair Tracker Project 2 Proposal
Department of Computer Science and Engineering, Texas A&M University
CSCE 606: Software Engineering, Section 700
Philip Ritchey
Gildas Mbouna, James Barrett, Pelumi Olutimehin, Hashim Balawi, and Jianqiu Wang
October 9th, 2026
________________
FixTrack: Equipment Maintenance and Repair Tracker
Team Members
1. Gildas Mbouna
2. James Barrett
3. Pelumi Olutimehin
4. Hashim Balawi
5. Jianqiu Wang
App Name
FixTrack - Equipment Maintenance & Repair Tracker
Short Description
FixTrack is a cloud-hosted web application that provides a modern solution to equipment problems faced by small engineering teams, laboratories, workshops, and maintenance organizations. Currently, there is no easy way for workers to tell whether equipment is available or not and whether a fault has been fixed and by whom. Workers must look through spreadsheets, emails, paper records, and informal conversations to track down the repair work that is being done on a particular piece of equipment.
This application allows managers to register equipment with its asset ID, description, location, and current status. When there is a problem, an authenticated user can register a maintenance ticket indicating what the problem is and its priority. The manager can assign a technician for the repair, and the technician can update the ticket and register the repair that has been made and the date when the repair was finished.
FixTrack connects every maintenance ticket and repair record to the specific equipment it relates to, so users can have a comprehensive history when making future decisions. Permissions are set based on roles, so only managers can make changes to equipment or assignments; technicians can only manage the tickets that have been assigned to them. FixTrack centralizes equipment information, assignments, ticket statuses, and a complete repair history to coordinate work and prevent missed or duplicative work.
Product Goal
At the end of this project, FixTrack will allow a maintenance team and equipment manager to track all equipment problems from initial report to resolution. FixTrack will accomplish this by allowing equipment management, maintenance tickets, assigning tickets to technicians, recording repairs, and tracking the status of equipment via a secure cloud-hosted web application.
Target Users and Stakeholders
Target Users
Maintenance Managers
• Register and manage equipment.
• Review maintenance tickets.
• Assign technicians.
• Monitor equipment and ticket status.
• Review repair history.
Technicians
• View assigned maintenance tickets.
• Diagnose reported problems.
• Update ticket status.
• Record repair work and resolution information.
Stakeholders
• Maintenance teams
• Engineering laboratories
• Workshops and makerspaces
• Small manufacturing or technical organizations
• Equipment owners and operators
• Organization administrators
These stakeholders benefit from accurate equipment status, documented maintenance history, and improved visibility into unresolved problems.
Core Problem and Value Proposition
A small maintenance crew will use spreadsheets and emails to keep track of any difficulties with the equipment. Paper records or telephone communication will be used to keep tabs on who has what down, who is working on it, what has been done, and what needs to be followed up on to see whether or not a problem was resolved.
FixTrack provides one place where all equipment, maintenance tickets, technicians, and repairs remain connected.
They won’t need to search through different emails or spreadsheets to know the equipment's current state and maintenance history, since everything is in one application.
MVP Features
1. User Authentication and Role-Based Authorization
Users can securely create accounts, log in, and log out.
The system supports at least two roles:
• Manager
• Technician
Authorization determines which actions each role can perform.
2. Equipment Management
Authorized managers can:
• Create equipment records.
• View equipment.
• Edit equipment information.
• Delete equipment when permitted.
• Track equipment status.
3. Maintenance Ticket Management
Authenticated users can create maintenance tickets for equipment.
Tickets include information such as:
• Equipment
• Problem description
• Priority
• Status
• Reporter
• Assigned technician
• Creation date
Users can view and update tickets according to their permissions.
4. Technician Assignment and Ticket Workflow
Managers can assign maintenance tickets to technicians.
Technicians can view their assigned tickets and update the workflow through states such as:
Open → Assigned → In Progress → Resolved
Invalid or unauthorized transitions will be rejected with an appropriate error message.
5. Repair Records and Equipment History
Technicians can document completed repair work.
Repair records contain information such as:
• Related maintenance ticket
• Technician
• Repair description
• Completion date
Users can view the maintenance and repair history associated with equipment.
Out-of-Scope Features
The following features are intentionally excluded from the required MVP:
• Real-time chat
• Mobile applications
• AI-based equipment diagnosis
• IoT equipment monitoring
• Payment processing
• Parts/inventory management
• External enterprise maintenance-system integration
• Advanced analytics
• SMS notifications
• Complex preventive-maintenance scheduling
These features would increase implementation and testing complexity without being necessary to demonstrate the required SaaS functionality.
Stretch Features
If the MVP is completed early, the team may attempt:
1. Preventive Maintenance Scheduling
• Managers can schedule recurring maintenance activities.
2. Email Notifications
• Users receive notifications for assignments or important ticket changes.
3. Maintenance Dashboard
• Summary information such as open tickets, resolved tickets, and equipment currently under repair.
Initial User Stories
US-1 - User Authentication
As a user, I want to securely log in to FixTrack so that I can access maintenance information appropriate to my account.
Acceptance considerations:
• Valid credentials allow access.
• Invalid credentials display an error.
• Unauthenticated users cannot access protected pages.
Estimate: 3 points


US-2 - Equipment Management
As a manager, I want to create, view, update, and remove equipment records so that the organization's equipment information remains accurate.
Acceptance considerations:
• Valid equipment can be created.
• Required fields cannot be blank.
• Unauthorized users cannot modify equipment.
• Invalid information displays an appropriate error.
Estimate: 5 points


US-3 - Report an Equipment Problem
As an authenticated user, I want to create a maintenance ticket for equipment so that a problem can be documented and addressed.
Acceptance considerations:
• A valid ticket is created successfully.
• The ticket is associated with equipment and its reporter.
• Missing required information is rejected.
• Validation errors are displayed clearly.
Estimate: 3 points


US-4 - Assign a Technician
As a manager, I want to assign a maintenance ticket to a technician so that responsibility for resolving the problem is clear.
Acceptance considerations:
• Managers can assign technicians.
• The assignment persists.
• Unauthorized users cannot assign technicians.
• Invalid assignments are rejected.
Estimate: 3 points


US-5 - Update Maintenance Ticket Status
As an assigned technician, I want to update the status of my maintenance ticket so that the team knows the current state of the repair.
Acceptance considerations:
• Authorized technicians can update assigned tickets.
• Status changes persist.
• Invalid status values are rejected.
• Unauthorized users cannot modify another technician's ticket.
Estimate: 3 points


US-6 - Record Completed Repair
As a technician, I want to document a completed repair so that future users can understand what work was performed on the equipment.
Acceptance considerations:
• A repair record is associated with a maintenance ticket.
• The technician and repair information are recorded.
• Required information is validated.
• Unauthorized users cannot create repair records for tickets they cannot manage.
Estimate: 5 points


US-7 - View Equipment Repair History
As an authenticated user, I want to view an equipment item's maintenance and repair history so that I can understand its previous problems and repairs.
Acceptance considerations:
• Users can see tickets associated with the equipment.
• Completed repair information is displayed.
• Records are associated with the correct equipment.
Estimate: 3 points


US-8 - Prevent Unauthorized Equipment Changes
As a manager, I want equipment-management operations restricted by role so that unauthorized users cannot change important equipment information.
Acceptance considerations:
• Technicians cannot access manager-only modification actions.
• Direct attempts to access restricted actions are rejected.
• Authorized managers retain access.
Estimate: 3 points


US-9 - Prevent Invalid Ticket Data
As a user, I want FixTrack to reject incomplete or invalid maintenance tickets so that the maintenance database contains useful information.
Acceptance considerations:
• Required fields are validated.
• Invalid values are rejected.
• The user receives understandable error messages.
• Invalid records are not persisted.
Estimate: 2 points
US-10 - Preventive Maintenance Scheduling - Stretch
As a manager, I want to schedule preventive maintenance for equipment so that maintenance can occur before avoidable failures happen.
Estimate: 5 points
Initial Data Model
User
Important fields:
• id
• name
• email
• password_digest
• role
• timestamps
Relationships:
• A user can report many maintenance tickets.
• A technician can be assigned many maintenance tickets.
• A technician can create many repair records.
Equipment
Important fields:
• id
• name
• asset_identifier
• description
• location
• status
• timestamps
Relationships:
• Equipment has many maintenance tickets.
• Equipment has repair history through its tickets and repair records.


MaintenanceTicket
Important fields:
• id
• equipment_id
• reporter_id
• assigned_technician_id
• title
• description
• priority
• status
• timestamps


Relationships:
• Belongs to equipment.
• Belongs to a reporting user.
• May belong to an assigned technician.
• May have one or more repair records.


RepairRecord
Important fields:
• id
• maintenance_ticket_id
• technician_id
• description
• completed_at
• timestamps
Relationships:
• Belongs to a maintenance ticket.
• Belongs to a technician.


Optional Location Model
If locations need to be managed independently rather than stored directly on equipment:
Important fields:
• id
• name
• description
Relationships:
• A location has many equipment records.
• Equipment belongs to a location.
The team will decide during initial design whether Location provides enough domain value to justify a separate model.
Authentication and Authorization Plan
FixTrack will support two primary roles:
Manager
Can:
• Manage equipment.
• View maintenance tickets.
• Assign technicians.
• Manage ticket workflow.
• Review repair history.
Technician
Can:
• View relevant maintenance tickets.
• View assigned work.
• Update authorized tickets.
• Create repair records.
• View equipment history.
Actions Requiring Authentication
At minimum:
1. Creating a maintenance ticket.
2. Viewing protected maintenance information.
3. Updating ticket status.
4. Creating a repair record.
Actions Restricted by Role
At minimum:
1. Only managers can create, edit, or delete managed equipment records.
2. Only managers can assign maintenance tickets to technicians.
Additional authorization rules will prevent technicians from changing tickets or records for which they do not have permission.
Testing Plan
FixTrack will use both Cucumber acceptance tests and RSpec unit tests.
Cucumber Acceptance Tests
Expected scenarios include:
• Successful login.
• Failed login.
• Manager successfully creates equipment.
• Equipment creation fails with missing required information.
• Unauthorized technician attempts to modify equipment.
• User successfully creates a maintenance ticket.
• Invalid maintenance ticket is rejected.
• Manager assigns a technician.
• Unauthorized user attempts an assignment.
• Technician updates an assigned ticket.
• Technician records a completed repair.
• User views equipment repair history.
Each feature will contain appropriate happy-path and sad-path scenarios.
Cucumber scenarios will be kept concise and independent.
RSpec Unit Tests
Expected tests include:
• Model validations.
• Model relationships.
• User roles.
• Equipment validations.
• Maintenance-ticket validations.
• Repair-record validations.
• Authorization behavior.
• Ticket workflow rules.
• Invalid-data handling.
The team will maintain:
• At least 90% Cucumber/acceptance-test coverage.
• At least 90% RSpec/unit-test coverage.
• At least 90% total test coverage.
Tests will be maintained throughout development rather than added only at the end.
Deployment Plan
FixTrack will be deployed as a cloud-hosted production web application.
The application will use:
• Ruby on Rails
• A relational database
• Server-rendered HTML
• Production cloud hosting
Cloud platform: [TEAM TO DECIDE]. The exact approved cloud platform will be selected by the team before implementation based on course compatibility and deployment requirements.
Each completed Increment will be deployed to the production environment.
The application will remain functional with JavaScript disabled and will use semantic HTML and accessible forms/navigation to target WCAG Level AA requirements.
Risks and Mitigations
Risk 1 - Excessive Project Scope
Risk: Too many features may prevent completion of a well-tested MVP.
Mitigation: Prioritize the five MVP capabilities and defer optional functionality to stretch goals.
Risk 2 - Integration Conflicts
Risk: Six developers working simultaneously may create merge conflicts or incompatible changes.
Mitigation: Use small feature branches, clear ownership, frequent integration, peer-reviewed pull requests, and regular communication.
Risk 3 - Insufficient Test Coverage
Risk: Development may progress faster than testing, resulting in coverage below 90%.
Mitigation: Write acceptance and unit tests alongside each feature and make testing part of the Definition of Done.
Risk 4 - Authorization Defects
Risk: Users may gain access to operations that should be restricted.
Mitigation: Define permissions early and test both authorized and unauthorized behavior.
Risk 5 - Deployment Problems
Risk: Features may work locally but fail in production.
Mitigation: Deploy completed Increments throughout the project rather than waiting until the end.
Risk 6 - Uneven Team Workload
Risk: Some developers may receive substantially more work than others.
Mitigation: Break stories into appropriately sized work, monitor the Sprint Backlog and burndown, and redistribute work during Daily Scrums when necessary.
Scrum Logistics
The team will conduct at least two Sprints.
Sprint Planning
Sprint Planning will occur at the beginning of each Sprint.
During Sprint Planning, the team will:
• Establish the Sprint Goal.
• Select Product Backlog items.
• Break selected items into actionable work.
• Assign or coordinate development responsibilities.
Daily Scrum
The team will hold a Daily Scrum at:
Time: [TEAM TO DECIDE]
Location/Platform: [TEAM TO DECIDE]
The Daily Scrum will:
• Occur at the same time and place each working day.
• Last no more than 15 minutes.
• Include all developers.
• Produce an actionable plan for the next working day.
Sprint Review
The Sprint Review will occur near the end of each Sprint.
The team will demonstrate the completed Increment and discuss progress toward the Product Goal with a TA or instructor.
Sprint Retrospective
The Sprint Retrospective will occur after the Sprint Review and will be the final event of each Sprint.
The team will discuss:
• What went well.
• What did not go well.
• What should change.
• Improvements to carry into the next Sprint.
Initial Product Backlog
Priority
	Story
	Points
	Type
	1
	US-1 User authentication
	3
	Essential
	2
	US-2 Equipment management
	5
	Essential
	3
	US-3 Report an equipment problem
	3
	Essential
	4
	US-4 Assign a technician
	3
	Essential
	5
	US-5 Update ticket status
	3
	Essential
	6
	US-6 Record completed repair
	5
	Essential
	7
	US-7 View equipment repair history
	3
	Essential
	8
	US-8 Prevent unauthorized equipment changes
	3
	Error/Security
	9
	US-9 Prevent invalid ticket data
	2
	Error Handling
	10
	US-10 Preventive maintenance scheduling
	5
	Stretch
	

Initial estimated backlog: 35 story points
Story estimates are preliminary and may change through backlog refinement.
Definition of Done
The team proposes using the course's standard Definition of Done without relaxation.
A Product Backlog item is considered done when:
1. The feature has associated user stories.
2. The feature has Cucumber acceptance tests covering appropriate happy and sad paths.
3. Relevant RSpec unit tests have been added or updated.
4. All tests are passing.
5. Cucumber/acceptance-test coverage is at least 90%.
6. RSpec/unit-test coverage is at least 90%.
7. Total test coverage is at least 90%.
8. RuboCop reports no correctable offenses and satisfies the course requirements.
9. Development occurs on an appropriately named feature branch.
10. The feature is reviewed and approved through a pull request by another team member.
11. The completed Increment is deployed to the production environment.
12. Documentation is updated whenever behavior, setup, architecture, or usage changes.
The team will also maintain technical deployment documentation, architectural diagrams, and an end-user guide throughout development.
No amendments to the standard Definition of Done are proposed.