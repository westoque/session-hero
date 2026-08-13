require "rails_helper"

RSpec.describe "Demos", type: :request do
  it "provisions a demo and lands in the organizer console" do
    expect { post "/demo" }.to change { Event.demo.count }.by(1)
    event = Event.demo.order(:created_at).last
    expect(response).to redirect_to(event_manage_root_path(event))
  end

  it "reuses the same sandbox on a second click (no duplicate)" do
    post "/demo"
    first = Event.demo.sole
    expect(Event.demo.count).to eq(1)

    # Same session (still signed in as the demo user) → back to the same demo.
    expect { post "/demo" }.not_to change { Event.demo.count }
    expect(response).to redirect_to(event_manage_root_path(first))
  end

  it "rejects new demos once the global cap is reached" do
    stub_const("DemosController::MAX_ACTIVE_DEMOS", 0)
    expect { post "/demo" }.not_to change { Event.demo.count }
    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to match(/capacity/i)
  end
end
