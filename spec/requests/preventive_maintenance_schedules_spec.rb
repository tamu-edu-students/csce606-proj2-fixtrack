require "rails_helper"

RSpec.describe "Preventive maintenance schedules", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:company) { Company.create!(name: "Preventive maintenance test") }
  let(:manager) { User.create!(name: "Manager", email: "pm-manager@example.test", password: "Schedule-test-123!", role: "manager", company: company) }
  let(:equipment) { Equipment.create!(name: "Pump", asset_identifier: "PM-013", location: "Lab", status: "Available") }
  let(:payload) { { preventive_maintenance_schedule: { task: "Inspect bearings", due_date: Date.tomorrow.iso8601 } } }

  before { sign_in manager }

  it "saves exactly one schedule and displays it after redirect and reload" do
    get new_equipment_preventive_maintenance_schedule_path(equipment)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Task", "Due date", "Save schedule")

    expect do
      post equipment_preventive_maintenance_schedules_path(equipment), params: payload
    end.to change(PreventiveMaintenanceSchedule, :count).by(1)
    expect(response).to redirect_to(equipment_preventive_maintenance_schedules_path(equipment))
    follow_redirect!
    expect(response.body).to include("Preventive maintenance scheduled successfully.", "Inspect bearings", Date.tomorrow.iso8601)
    get equipment_preventive_maintenance_schedules_path(equipment)
    expect(response.body).to include("Inspect bearings")
  end

  [ nil, "", "   " ].each do |task|
    it "rejects task #{task.inspect} with field-level errors" do
      expect do
        post equipment_preventive_maintenance_schedules_path(equipment), params: {
          preventive_maintenance_schedule: payload[:preventive_maintenance_schedule].merge(task: task)
        }
      end.not_to change(PreventiveMaintenanceSchedule, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("task-errors", "Task can&#39;t be blank")
    end
  end

  [ :today, :yesterday, :invalid, :blank ].each do |date_type|
    it "rejects #{date_type} as a due date without losing the entered task" do
      date = { today: Date.current.iso8601, yesterday: Date.yesterday.iso8601, invalid: "not-a-date", blank: "" }.fetch(date_type)
      expect do
        post equipment_preventive_maintenance_schedules_path(equipment), params: {
          preventive_maintenance_schedule: { task: "Keep this task", due_date: date }
        }
      end.not_to change(PreventiveMaintenanceSchedule, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("due-date-errors", "Keep this task")
    end
  end

  %w[technician reporter].each do |role|
    it "allows a #{role} to read but denies both form access and direct creation" do
      manager.update!(role: role)
      get equipment_preventive_maintenance_schedules_path(equipment)
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("Schedule preventive maintenance")
      get new_equipment_preventive_maintenance_schedule_path(equipment)
      expect(response).to have_http_status(:forbidden)
      expect do
        post equipment_preventive_maintenance_schedules_path(equipment), params: payload
      end.not_to change(PreventiveMaintenanceSchedule, :count)
      expect(response).to have_http_status(:forbidden)
    end
  end

  it "requires authentication for the list, form, and direct creation" do
    sign_out manager
    [ equipment_preventive_maintenance_schedules_path(equipment), new_equipment_preventive_maintenance_schedule_path(equipment) ].each do |path|
      get path
      expect(response).to redirect_to(new_user_session_path)
    end
    expect do
      post equipment_preventive_maintenance_schedules_path(equipment), params: payload
    end.not_to change(PreventiveMaintenanceSchedule, :count)
    expect(response).to redirect_to(new_user_session_path)
  end

  it "lists only the selected equipment's work, in due-date order, including overdue work" do
    other = Equipment.create!(name: "Other pump", asset_identifier: "OTHER-PM", location: "Office", status: "Available")
    equipment.preventive_maintenance_schedules.create!(task: "Later task", due_date: Date.current + 5)
    overdue = equipment.preventive_maintenance_schedules.create!(task: "Earlier task", due_date: Date.tomorrow)
    overdue.update_column(:due_date, Date.yesterday)
    other.preventive_maintenance_schedules.create!(task: "Unrelated task", due_date: Date.tomorrow)
    get equipment_preventive_maintenance_schedules_path(equipment)
    expect(response.body).not_to include("Unrelated task")
    expect(Nokogiri::HTML(response.body).css("tbody tr td:first-child").map(&:text)).to eq([ "Earlier task", "Later task" ])
  end

  it "ignores an equipment ID injected into the schedule payload" do
    other = Equipment.create!(name: "Other pump", asset_identifier: "OTHER-PM", location: "Office", status: "Available")
    post equipment_preventive_maintenance_schedules_path(equipment), params: {
      preventive_maintenance_schedule: payload[:preventive_maintenance_schedule].merge(equipment_id: other.id)
    }
    expect(PreventiveMaintenanceSchedule.last.equipment_id).to eq(equipment.id)
  end

  it "shows an empty state and a link from the equipment record" do
    get equipment_path(equipment)
    expect(response.body).to include(equipment_preventive_maintenance_schedules_path(equipment))
    get equipment_preventive_maintenance_schedules_path(equipment)
    expect(response.body).to include("No preventive maintenance is scheduled for this equipment.")
  end

  it "returns a controlled not-found response for missing equipment" do
    get equipment_preventive_maintenance_schedules_path(equipment_id: 0)
    expect(response).to have_http_status(:not_found)
    expect(response.body).to include("Equipment not found.")
  end

  it "explains a blocked equipment removal without losing its schedule" do
    equipment.preventive_maintenance_schedules.create!(task: "Keep this scheduled work", due_date: Date.tomorrow)
    expect do
      delete equipment_path(equipment)
    end.not_to change(Equipment, :count)
    expect(response).to redirect_to(equipment_path(equipment))
    follow_redirect!
    expect(response.body).to include("Cannot delete record")
    expect(PreventiveMaintenanceSchedule.find_by!(task: "Keep this scheduled work").equipment_id).to eq(equipment.id)
  end
end
