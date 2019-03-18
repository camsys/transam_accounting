# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_02_27_192638) do

  create_table "activities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12
    t.integer "organization_type_id"
    t.string "name", limit: 64
    t.text "description"
    t.boolean "show_in_dashboard"
    t.boolean "system_activity"
    t.date "start_date"
    t.date "end_date"
    t.integer "frequency_quantity", null: false
    t.integer "frequency_type_id", null: false
    t.string "execution_time", limit: 32, null: false
    t.string "job_name", limit: 64
    t.datetime "last_run"
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activity_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.string "item_type", limit: 64, null: false
    t.integer "item_id"
    t.integer "user_id", null: false
    t.text "activity", limit: 4294967295, null: false
    t.datetime "activity_time"
    t.index ["organization_id", "activity_time"], name: "activity_logs_idx1"
    t.index ["user_id", "activity_time"], name: "activity_logs_idx2"
  end

  create_table "archived_fiscal_years", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_id"
    t.integer "fy_year"
    t.index ["organization_id"], name: "index_archived_fiscal_years_on_organization_id"
  end

  create_table "asset_event_asset_subsystems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_event_id"
    t.integer "asset_subsystem_id"
    t.integer "parts_cost"
    t.integer "labor_cost"
    t.index ["asset_event_id"], name: "rehab_events_subsystems_idx1"
    t.index ["asset_subsystem_id"], name: "rehab_events_subsystems_idx2"
  end

  create_table "asset_event_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "class_name", limit: 64, null: false
    t.string "job_name", limit: 64, null: false
    t.string "display_icon_name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.index ["class_name"], name: "asset_event_types_idx1"
  end

  create_table "asset_events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "asset_id"
    t.string "transam_asset_type"
    t.bigint "transam_asset_id"
    t.bigint "base_transam_asset_id"
    t.integer "asset_event_type_id", null: false
    t.integer "upload_id"
    t.date "event_date", null: false
    t.datetime "event_datetime"
    t.decimal "assessed_rating", precision: 9, scale: 2
    t.integer "condition_type_id"
    t.integer "current_mileage"
    t.integer "parent_id"
    t.integer "replacement_year"
    t.integer "rebuild_year"
    t.integer "disposition_year"
    t.integer "extended_useful_life_miles"
    t.integer "extended_useful_life_months"
    t.integer "replacement_reason_type_id"
    t.date "disposition_date"
    t.integer "disposition_type_id"
    t.integer "service_status_type_id"
    t.boolean "fta_emergency_contingency_fleet"
    t.integer "maintenance_type_id"
    t.integer "pcnt_5311_routes"
    t.integer "avg_daily_use_hours"
    t.integer "avg_daily_use_miles"
    t.integer "avg_daily_passenger_trips"
    t.integer "maintenance_provider_type_id"
    t.integer "vehicle_storage_method_type_id"
    t.decimal "avg_cost_per_mile", precision: 9, scale: 2
    t.decimal "avg_miles_per_gallon", precision: 9, scale: 2
    t.integer "annual_maintenance_cost"
    t.integer "annual_insurance_cost"
    t.boolean "actual_costs"
    t.integer "annual_affected_ridership"
    t.integer "annual_dollars_generated"
    t.integer "sales_proceeds"
    t.decimal "speed_restriction", precision: 10, scale: 5
    t.string "speed_restriction_unit"
    t.integer "period_length"
    t.string "period_length_unit"
    t.string "from_line"
    t.string "to_line"
    t.decimal "from_segment", precision: 7, scale: 2
    t.decimal "to_segment", precision: 7, scale: 2
    t.string "segment_unit"
    t.string "from_location_name"
    t.string "to_location_name"
    t.bigint "infrastructure_chain_type_id"
    t.decimal "relative_location", precision: 10, scale: 5
    t.string "relative_location_unit"
    t.string "relative_location_direction"
    t.bigint "performance_restriction_type_id"
    t.integer "num_infrastructure"
    t.integer "book_value"
    t.text "comments"
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state", limit: 32
    t.string "document", limit: 128
    t.string "original_filename", limit: 128
    t.integer "created_by_id"
    t.integer "total_cost"
    t.integer "general_ledger_account_id"
    t.index ["asset_event_type_id"], name: "asset_events_idx3"
    t.index ["asset_id"], name: "asset_events_idx2"
    t.index ["base_transam_asset_id"], name: "index_asset_events_on_base_transam_asset_id"
    t.index ["created_by_id"], name: "asset_events_creator_idx"
    t.index ["event_date"], name: "asset_events_idx4"
    t.index ["infrastructure_chain_type_id"], name: "index_asset_events_on_infrastructure_chain_type_id"
    t.index ["object_key"], name: "asset_events_idx1"
    t.index ["performance_restriction_type_id"], name: "index_asset_events_on_performance_restriction_type_id"
    t.index ["transam_asset_id"], name: "index_asset_events_on_transam_asset_id"
    t.index ["upload_id"], name: "asset_events_idx5"
  end

  create_table "asset_events_vehicle_usage_codes", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_event_id"
    t.integer "vehicle_usage_code_id"
    t.index ["asset_event_id", "vehicle_usage_code_id"], name: "asset_events_vehicle_usage_codes_idx1"
  end

  create_table "asset_fleet_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "class_name"
    t.text "groups"
    t.text "custom_groups"
    t.string "label_groups"
    t.boolean "active"
  end

  create_table "asset_fleets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key"
    t.integer "organization_id"
    t.integer "asset_fleet_type_id"
    t.string "agency_fleet_id"
    t.string "fleet_name"
    t.integer "ntd_id"
    t.integer "estimated_cost"
    t.integer "year_estimated_cost"
    t.text "notes"
    t.integer "created_by_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["object_key"], name: "index_asset_fleets_on_object_key"
    t.index ["organization_id"], name: "index_asset_fleets_on_organization_id"
  end

  create_table "asset_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id", null: false
    t.string "name", limit: 64, null: false
    t.string "code", limit: 8, null: false
    t.string "description", limit: 254
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["object_key"], name: "asset_groups_idx1"
    t.index ["organization_id"], name: "asset_groups_idx2"
  end

  create_table "asset_groups_assets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_id"
    t.bigint "transam_asset_id"
    t.integer "asset_group_id", null: false
    t.index ["asset_id", "asset_group_id"], name: "asset_groups_assets_idx1"
    t.index ["transam_asset_id"], name: "index_asset_groups_assets_on_transam_asset_id"
  end

  create_table "asset_subsystems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64
    t.string "code", limit: 2
    t.string "description", limit: 254
    t.integer "asset_type_id"
    t.boolean "active"
  end

  create_table "asset_subtypes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_type_id", null: false
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.string "image", limit: 254
    t.boolean "active", null: false
    t.index ["asset_type_id"], name: "asset_subtypes_idx1"
  end

  create_table "asset_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_id"
    t.integer "user_id"
    t.index ["asset_id"], name: "asset_tags_idx1"
    t.index ["user_id"], name: "asset_tags_idx2"
  end

  create_table "asset_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "class_name", limit: 64, null: false
    t.string "display_icon_name", limit: 64, null: false
    t.string "map_icon_name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "allow_parent"
    t.boolean "active", null: false
    t.index ["class_name"], name: "asset_types_idx1"
    t.index ["name"], name: "asset_types_idx2"
  end

  create_table "asset_types_manufacturers", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_type_id"
    t.integer "manufacturer_id"
    t.index ["asset_type_id", "manufacturer_id"], name: "asset_types_manufacturers_idx1"
  end

  create_table "assets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id", null: false
    t.integer "asset_type_id", null: false
    t.integer "asset_subtype_id", null: false
    t.string "asset_tag", limit: 32, null: false
    t.string "external_id", limit: 32
    t.integer "parent_id"
    t.integer "superseded_by_id"
    t.integer "manufacturer_id"
    t.string "other_manufacturer"
    t.string "manufacturer_model", limit: 128
    t.integer "manufacture_year"
    t.integer "pcnt_capital_responsibility"
    t.integer "vendor_id"
    t.integer "policy_replacement_year"
    t.integer "policy_rehabilitation_year"
    t.integer "estimated_replacement_year"
    t.integer "estimated_replacement_cost"
    t.integer "scheduled_replacement_year"
    t.integer "scheduled_rehabilitation_year"
    t.integer "scheduled_disposition_year"
    t.integer "scheduled_replacement_cost"
    t.text "early_replacement_reason"
    t.boolean "scheduled_replace_with_new"
    t.integer "scheduled_rehabilitation_cost"
    t.integer "replacement_reason_type_id"
    t.boolean "in_backlog"
    t.integer "reported_condition_type_id"
    t.decimal "reported_condition_rating", precision: 10, scale: 1
    t.integer "reported_mileage"
    t.date "reported_mileage_date"
    t.date "reported_condition_date"
    t.integer "estimated_condition_type_id"
    t.decimal "estimated_condition_rating", precision: 9, scale: 2
    t.integer "service_status_type_id"
    t.date "service_status_date"
    t.date "last_maintenance_date"
    t.boolean "depreciable"
    t.date "depreciation_start_date"
    t.integer "depreciation_useful_life"
    t.integer "depreciation_purchase_cost"
    t.date "current_depreciation_date"
    t.integer "book_value"
    t.integer "salvage_value"
    t.date "disposition_date"
    t.integer "disposition_type_id"
    t.date "last_rehabilitation_date"
    t.integer "maintenance_provider_type_id"
    t.integer "vehicle_storage_method_type_id"
    t.integer "vehicle_rebuild_type_id"
    t.integer "location_reference_type_id"
    t.string "location_reference", limit: 254
    t.text "location_comments"
    t.integer "fuel_type_id"
    t.integer "vehicle_length"
    t.integer "gross_vehicle_weight"
    t.string "title_number", limit: 32
    t.integer "title_owner_organization_id"
    t.string "serial_number", limit: 32
    t.boolean "purchased_new"
    t.integer "purchase_cost"
    t.date "purchase_date"
    t.date "warranty_date"
    t.date "in_service_date"
    t.integer "expected_useful_life"
    t.integer "expected_useful_miles"
    t.integer "rebuild_year"
    t.string "license_plate", limit: 32
    t.integer "seating_capacity"
    t.integer "standing_capacity"
    t.integer "wheelchair_capacity"
    t.integer "fta_ownership_type_id"
    t.string "other_fta_ownership_type"
    t.integer "fta_vehicle_type_id"
    t.integer "fta_support_vehicle_type_id"
    t.integer "fta_funding_type_id"
    t.integer "fta_bus_mode_type_id"
    t.boolean "ada_accessible_lift"
    t.boolean "ada_accessible_ramp"
    t.boolean "fta_emergency_contingency_fleet"
    t.boolean "dedicated"
    t.string "description", limit: 128
    t.string "address1", limit: 128
    t.string "address2", limit: 128
    t.string "city", limit: 64
    t.string "state", limit: 2
    t.string "zip", limit: 10
    t.integer "facility_size"
    t.boolean "section_of_larger_facility"
    t.integer "pcnt_operational"
    t.integer "num_floors"
    t.integer "num_structures"
    t.integer "num_elevators"
    t.integer "num_escalators"
    t.integer "num_parking_spaces_public"
    t.integer "num_parking_spaces_private"
    t.decimal "lot_size", precision: 9, scale: 2
    t.string "line_number", limit: 128
    t.integer "land_ownership_type_id"
    t.integer "land_ownership_organization_id"
    t.integer "building_ownership_type_id"
    t.integer "building_ownership_organization_id"
    t.integer "facility_capacity_type_id"
    t.integer "fta_facility_type_id"
    t.integer "fta_private_mode_type_id"
    t.integer "leed_certification_type_id"
    t.integer "quantity"
    t.string "quantity_units", limit: 16
    t.integer "created_by_id"
    t.integer "weight"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "upload_id"
    t.integer "location_id"
    t.integer "dual_fuel_type_id"
    t.string "other_fuel_type"
    t.index ["asset_subtype_id"], name: "assets_idx4"
    t.index ["asset_type_id"], name: "assets_idx3"
    t.index ["estimated_replacement_year"], name: "assets_idx8"
    t.index ["in_backlog"], name: "assets_idx7"
    t.index ["manufacture_year"], name: "assets_idx5"
    t.index ["object_key"], name: "assets_idx1"
    t.index ["organization_id", "asset_subtype_id", "in_backlog"], name: "assets_idx12"
    t.index ["organization_id", "asset_subtype_id", "policy_replacement_year"], name: "assets_idx10"
    t.index ["organization_id", "in_backlog"], name: "assets_idx11"
    t.index ["organization_id", "policy_replacement_year"], name: "assets_idx9"
    t.index ["organization_id"], name: "assets_idx2"
    t.index ["reported_condition_type_id"], name: "assets_idx6"
    t.index ["superseded_by_id"], name: "assets_idx13"
  end

  create_table "assets_asset_fleets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_id"
    t.bigint "transam_asset_id"
    t.integer "asset_fleet_id"
    t.boolean "active"
    t.index ["asset_fleet_id"], name: "index_assets_asset_fleets_on_asset_fleet_id"
    t.index ["asset_id"], name: "index_assets_asset_fleets_on_asset_id"
    t.index ["transam_asset_id"], name: "index_assets_asset_fleets_on_transam_asset_id"
  end

  create_table "assets_districts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_id"
    t.bigint "transam_asset_id"
    t.integer "district_id"
    t.index ["asset_id", "district_id"], name: "assets_districts_idx1"
    t.index ["transam_asset_id"], name: "index_assets_districts_on_transam_asset_id"
  end

  create_table "assets_expenditures", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_id", null: false
    t.bigint "transam_asset_id"
    t.integer "expenditure_id", null: false
    t.index ["asset_id", "expenditure_id"], name: "assets_expenditures_idx1"
    t.index ["transam_asset_id"], name: "index_assets_expenditures_on_transam_asset_id"
  end

  create_table "assets_facility_features", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_id"
    t.bigint "transam_asset_id"
    t.integer "facility_feature_id", null: false
    t.index ["asset_id", "facility_feature_id"], name: "assets_facility_features_idx1"
    t.index ["transam_asset_id", "facility_feature_id"], name: "transam_assets_facility_features_idx1"
    t.index ["transam_asset_id"], name: "index_assets_facility_features_on_transam_asset_id"
  end

  create_table "assets_fta_mode_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_id"
    t.string "transam_asset_type"
    t.bigint "transam_asset_id"
    t.integer "fta_mode_type_id"
    t.boolean "is_primary"
    t.index ["asset_id", "fta_mode_type_id"], name: "assets_fta_mode_types_idx1"
    t.index ["transam_asset_id"], name: "index_assets_fta_mode_types_on_transam_asset_id"
  end

  create_table "assets_fta_service_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_id"
    t.string "transam_asset_type"
    t.bigint "transam_asset_id"
    t.integer "fta_service_type_id"
    t.boolean "is_primary"
    t.index ["asset_id", "fta_service_type_id"], name: "assets_fta_service_types_idx1"
    t.index ["transam_asset_id"], name: "index_assets_fta_service_types_on_transam_asset_id"
  end

  create_table "assets_vehicle_features", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_id"
    t.bigint "transam_asset_id"
    t.integer "vehicle_feature_id"
    t.index ["asset_id", "vehicle_feature_id"], name: "assets_vehicle_features_idx1"
    t.index ["transam_asset_id"], name: "index_assets_vehicle_features_on_transam_asset_id"
  end

  create_table "assets_vehicle_usage_codes", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_id", null: false
    t.integer "vehicle_usage_code_id", null: false
    t.index ["asset_id", "vehicle_usage_code_id"], name: "assets_vehicle_usage_codes_idx1"
  end

  create_table "chart_of_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12
    t.integer "organization_id"
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["organization_id"], name: "chart_of_accounts_idx1"
  end

  create_table "chasses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "commentable_id", null: false
    t.string "commentable_type", limit: 64, null: false
    t.string "comment", limit: 254, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["commentable_id", "commentable_type"], name: "comments_idx1"
  end

  create_table "component_element_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "component_type_id"
    t.boolean "active"
    t.index ["component_type_id"], name: "index_component_element_types_on_component_type_id"
  end

  create_table "component_materials", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "component_type_id"
    t.bigint "component_element_type_id"
    t.boolean "active"
    t.index ["component_element_type_id"], name: "index_component_materials_on_component_element_type_id"
    t.index ["component_type_id"], name: "index_component_materials_on_component_type_id"
  end

  create_table "component_subtypes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "parent_type"
    t.bigint "parent_id"
    t.string "name"
    t.boolean "active"
    t.index ["parent_type", "parent_id"], name: "index_component_subtypes_on_parent_type_and_parent_id"
  end

  create_table "component_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "fta_asset_category_id"
    t.bigint "fta_asset_class_id"
    t.string "name"
    t.string "class_name"
    t.boolean "active"
    t.index ["fta_asset_category_id"], name: "index_component_types_on_fta_asset_category_id"
    t.index ["fta_asset_class_id"], name: "index_component_types_on_fta_asset_class_id"
  end

  create_table "condition_estimation_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "class_name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.index ["class_name"], name: "condition_estimation_types_idx1"
  end

  create_table "condition_rollup_calculation_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "class_name"
    t.string "description"
    t.boolean "active"
  end

  create_table "condition_type_percents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_event_id"
    t.integer "condition_type_id"
    t.integer "pcnt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["asset_event_id"], name: "index_condition_type_percents_on_asset_event_id"
    t.index ["condition_type_id"], name: "index_condition_type_percents_on_condition_type_id"
  end

  create_table "condition_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.decimal "rating", precision: 9, scale: 2, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "contract_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "cost_calculation_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "class_name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.index ["class_name"], name: "cost_calculation_types_idx1"
  end

  create_table "customers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "license_type_id", null: false
    t.string "name", limit: 64, null: false
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_job_priorities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "class_name", null: false
    t.integer "priority", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "priority"
    t.integer "attempts"
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "depreciation_calculation_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "class_name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "depreciation_entries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.bigint "asset_id"
    t.bigint "transam_asset_id"
    t.date "event_date"
    t.string "description"
    t.integer "book_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_depreciation_entries_on_asset_id"
    t.index ["transam_asset_id"], name: "index_depreciation_entries_on_transam_asset_id"
  end

  create_table "depreciation_entries_general_ledger_account_entries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "depreciation_entry_id"
    t.integer "general_ledger_account_entry_id"
    t.index ["depreciation_entry_id"], name: "depr_entry_idx"
    t.index ["general_ledger_account_entry_id"], name: "gl_entry_idx"
  end

  create_table "depreciation_interval_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.integer "months", null: false
    t.boolean "active", null: false
  end

  create_table "disposition_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "code", limit: 2, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "district_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "districts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "district_type_id", null: false
    t.string "name", limit: 64, null: false
    t.string "code"
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.index ["district_type_id"], name: "districts_idx1"
    t.index ["name"], name: "districts_idx2"
  end

  create_table "documents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "documentable_id", null: false
    t.string "documentable_type", limit: 64, null: false
    t.string "document", limit: 128, null: false
    t.string "description", limit: 254, null: false
    t.string "original_filename", limit: 128, null: false
    t.string "content_type", limit: 128, null: false
    t.integer "file_size", null: false
    t.integer "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["documentable_id", "documentable_type"], name: "documents_idx2"
    t.index ["object_key"], name: "documents_idx1"
  end

  create_table "dual_fuel_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "primary_fuel_type_id"
    t.integer "secondary_fuel_type_id"
    t.boolean "active"
    t.index ["primary_fuel_type_id"], name: "index_dual_fuel_types_on_primary_fuel_type_id"
    t.index ["secondary_fuel_type_id"], name: "index_dual_fuel_types_on_secondary_fuel_type_id"
  end

  create_table "esl_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "class_name"
    t.boolean "active"
  end

  create_table "expenditures", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "general_ledger_account_id"
    t.integer "grant_id"
    t.integer "expense_type_id", null: false
    t.string "external_id", limit: 32
    t.date "expense_date", null: false
    t.string "description", limit: 254
    t.integer "amount", null: false
    t.integer "extended_useful_life_months"
    t.string "vendor"
    t.integer "pcnt_from_grant"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["expense_type_id"], name: "expenditures_idx4"
    t.index ["general_ledger_account_id"], name: "expenditures_idx3"
    t.index ["object_key"], name: "expenditures_idx1"
  end

  create_table "expense_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.index ["name"], name: "expense_types_idx2"
  end

  create_table "facilities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "facility_name"
    t.string "ntd_id"
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "county"
    t.string "country"
    t.bigint "esl_category_id"
    t.bigint "facility_capacity_type_id"
    t.integer "facility_size"
    t.string "facility_size_unit"
    t.boolean "section_of_larger_facility"
    t.integer "num_structures"
    t.integer "num_floors"
    t.integer "num_elevators"
    t.integer "num_escalators"
    t.integer "num_parking_spaces_public"
    t.integer "num_parking_spaces_private"
    t.integer "lot_size"
    t.string "lot_size_unit"
    t.bigint "leed_certification_type_id"
    t.boolean "ada_accessible"
    t.bigint "fta_private_mode_type_id"
    t.bigint "land_ownership_organization_id"
    t.string "other_land_ownership_organization"
    t.bigint "facility_ownership_organization_id"
    t.string "other_facility_ownership_organization"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["esl_category_id"], name: "index_facilities_on_esl_category_id"
    t.index ["facility_capacity_type_id"], name: "index_facilities_on_facility_capacity_type_id"
    t.index ["facility_ownership_organization_id"], name: "index_facilities_on_facility_ownership_organization_id"
    t.index ["fta_private_mode_type_id"], name: "index_facilities_on_fta_private_mode_type_id"
    t.index ["land_ownership_organization_id"], name: "index_facilities_on_land_ownership_organization_id"
    t.index ["leed_certification_type_id"], name: "index_facilities_on_leed_certification_type_id"
  end

  create_table "facility_capacity_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "facility_features", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "code", limit: 4, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active"
  end

  create_table "file_content_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "class_name", limit: 64, null: false
    t.string "builder_name"
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.index ["class_name"], name: "file_content_types_idx2"
    t.index ["name"], name: "file_content_types_idx1"
  end

  create_table "file_status_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.index ["name"], name: "file_status_types_idx1"
  end

  create_table "forms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.string "roles", limit: 128, null: false
    t.string "controller", limit: 64, null: false
    t.integer "sort_order"
    t.boolean "active", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["object_key"], name: "forms_idx1"
  end

  create_table "frequency_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 32, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "fta_agency_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 256, null: false
    t.boolean "active", null: false
  end

  create_table "fta_asset_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "display_icon_name"
    t.boolean "active"
  end

  create_table "fta_asset_classes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "fta_asset_category_id"
    t.string "name"
    t.string "class_name"
    t.string "display_icon_name"
    t.boolean "active"
    t.index ["fta_asset_category_id"], name: "index_fta_asset_classes_on_fta_asset_category_id"
  end

  create_table "fta_bus_mode_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "code", limit: 4, null: false
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "fta_equipment_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "fta_asset_class_id"
    t.string "name"
    t.boolean "active"
    t.index ["fta_asset_class_id"], name: "index_fta_equipment_types_on_fta_asset_class_id"
  end

  create_table "fta_facility_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "fta_asset_class_id"
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.string "class_name"
    t.boolean "active", null: false
  end

  create_table "fta_funding_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "code", limit: 6, null: false
    t.string "description", limit: 256, null: false
    t.boolean "active", null: false
  end

  create_table "fta_guideway_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "fta_mode_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "code", limit: 2, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "fta_mode_types_organizations", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "fta_mode_type_id", null: false
    t.index ["organization_id", "fta_mode_type_id"], name: "fta_mode_types_organizations_idx1"
  end

  create_table "fta_ownership_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "code", limit: 4, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "fta_power_signal_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "fta_private_mode_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.boolean "active", null: false
  end

  create_table "fta_service_area_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "fta_service_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "code", limit: 2, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "fta_support_vehicle_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "fta_asset_class_id"
    t.string "name", null: false
    t.string "description", null: false
    t.integer "default_useful_life_benchmark"
    t.string "useful_life_benchmark_unit"
    t.boolean "active", null: false
  end

  create_table "fta_track_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "fta_vehicle_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "fta_asset_class_id"
    t.string "name", limit: 64, null: false
    t.string "code", limit: 2, null: false
    t.string "description", limit: 254, null: false
    t.integer "default_useful_life_benchmark"
    t.string "useful_life_benchmark_unit"
    t.boolean "active", null: false
  end

  create_table "fuel_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "description", null: false
    t.boolean "active", null: false
  end

  create_table "funding_bucket_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.boolean "active", null: false
  end

  create_table "funding_buckets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "funding_template_id", null: false
    t.integer "fiscal_year", null: false
    t.string "name", null: false
    t.decimal "budget_amount", precision: 15, scale: 2, null: false
    t.decimal "budget_committed", precision: 15, scale: 2, null: false
    t.integer "owner_id"
    t.string "description"
    t.boolean "active", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_on"
    t.integer "updated_by_id", null: false
    t.datetime "updated_on"
  end

  create_table "funding_source_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "funding_sources", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.string "name", limit: 64, null: false
    t.string "description", limit: 256, null: false
    t.text "details"
    t.integer "funding_source_type_id", null: false
    t.string "external_id", limit: 32
    t.boolean "formula_fund"
    t.boolean "discretionary_fund"
    t.float "match_required"
    t.integer "fy_start"
    t.integer "fy_end"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float "inflation_rate"
    t.integer "life_in_years"
    t.index ["object_key"], name: "funding_sources_idx1"
  end

  create_table "funding_template_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "funding_source_id"
    t.string "name", limit: 64, null: false
    t.string "description", limit: 256, null: false
    t.boolean "active", null: false
    t.index ["funding_source_id"], name: "index_funding_template_types_on_funding_source_id"
  end

  create_table "funding_templates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "funding_source_id"
    t.string "name", limit: 64, null: false
    t.text "description"
    t.integer "contributor_id", null: false
    t.integer "owner_id", null: false
    t.boolean "recurring"
    t.boolean "transfer_only"
    t.boolean "create_multiple_agencies", null: false
    t.boolean "create_multiple_buckets_for_agency_year", null: false
    t.float "match_required"
    t.text "query_string"
    t.boolean "active", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "external_id", limit: 32
    t.index ["contributor_id"], name: "index_funding_templates_on_contributor_id"
    t.index ["funding_source_id"], name: "index_funding_templates_on_funding_source_id"
    t.index ["owner_id"], name: "index_funding_templates_on_owner_id"
  end

  create_table "funding_templates_funding_template_types", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "funding_template_id"
    t.integer "funding_template_type_id"
    t.index ["funding_template_id"], name: "funding_templates_funding_template_types_idx1"
    t.index ["funding_template_type_id"], name: "funding_templates_funding_template_types_idx2"
  end

  create_table "funding_templates_organizations", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "funding_template_id"
    t.integer "organization_id"
    t.index ["funding_template_id"], name: "index_funding_templates_organizations_on_funding_template_id"
    t.index ["organization_id"], name: "index_funding_templates_organizations_on_organization_id"
  end

  create_table "general_ledger_account_entries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12
    t.integer "general_ledger_account_id"
    t.date "event_date"
    t.string "description"
    t.decimal "amount", precision: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "asset_id"
    t.bigint "transam_asset_id"
    t.index ["asset_id"], name: "index_general_ledger_account_entries_on_asset_id"
    t.index ["general_ledger_account_id"], name: "general_ledger_account_entry_general_ledger_account_idx"
    t.index ["transam_asset_id"], name: "index_general_ledger_account_entries_on_transam_asset_id"
  end

  create_table "general_ledger_account_subtypes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "general_ledger_account_type_id"
    t.string "name"
    t.string "description"
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "general_ledger_account_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "general_ledger_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "chart_of_account_id", null: false
    t.integer "general_ledger_account_type_id", null: false
    t.integer "general_ledger_account_subtype_id"
    t.string "account_number", null: false
    t.string "name", null: false
    t.boolean "active", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "grant_id"
    t.index ["active"], name: "general_ledger_accounts_idx3"
    t.index ["chart_of_account_id"], name: "general_ledger_accounts_idx2"
    t.index ["object_key"], name: "general_ledger_accounts_idx1"
  end

  create_table "general_ledger_mappings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.bigint "chart_of_account_id"
    t.bigint "asset_subtype_id"
    t.bigint "asset_account_id"
    t.bigint "depr_expense_account_id"
    t.bigint "accumulated_depr_account_id"
    t.bigint "gain_loss_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accumulated_depr_account_id"], name: "index_general_ledger_mappings_on_accumulated_depr_account_id"
    t.index ["asset_account_id"], name: "index_general_ledger_mappings_on_asset_account_id"
    t.index ["asset_subtype_id"], name: "index_general_ledger_mappings_on_asset_subtype_id"
    t.index ["chart_of_account_id"], name: "index_general_ledger_mappings_on_chart_of_account_id"
    t.index ["depr_expense_account_id"], name: "index_general_ledger_mappings_on_depr_expense_account_id"
    t.index ["gain_loss_account_id"], name: "index_general_ledger_mappings_on_gain_loss_account_id"
  end

  create_table "governing_body_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "grant_amendments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.bigint "grant_id"
    t.string "amendment_num"
    t.string "grant_num"
    t.text "comments"
    t.integer "created_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grant_id"], name: "index_grant_amendments_on_grant_id"
  end

  create_table "grant_apportionments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.bigint "grant_id"
    t.string "sourceable_type"
    t.bigint "sourceable_id"
    t.string "name"
    t.integer "fy_year"
    t.integer "amount"
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grant_id"], name: "index_grant_apportionments_on_grant_id"
    t.index ["sourceable_type", "sourceable_id"], name: "index_grant_apportionments_on_sourceable_type_and_sourceable_id"
  end

  create_table "grant_budgets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "general_ledger_account_id", null: false
    t.integer "grant_id", null: false
    t.integer "amount", null: false
    t.boolean "active"
    t.index ["general_ledger_account_id", "grant_id"], name: "grant_budgets_idx1"
  end

  create_table "grant_purchases", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "asset_id"
    t.bigint "transam_asset_id"
    t.integer "pcnt_purchase_cost", null: false
    t.string "expense_tag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sourceable_id"
    t.string "sourceable_type"
    t.string "other_sourceable"
    t.index ["asset_id"], name: "grant_purchases_idx1"
    t.index ["transam_asset_id"], name: "index_grant_purchases_on_transam_asset_id"
  end

  create_table "grants", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "owner_id", null: false
    t.bigint "contributor_id"
    t.boolean "has_multiple_contributors"
    t.string "other_contributor"
    t.integer "fy_year", null: false
    t.date "award_date"
    t.integer "amount", null: false
    t.string "legislative_authorization"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sourceable_id"
    t.string "sourceable_type"
    t.boolean "over_allocation_allowed"
    t.string "state"
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.boolean "active"
    t.string "grant_num"
    t.index ["contributor_id"], name: "index_grants_on_contributor_id"
    t.index ["fy_year"], name: "grants_idx3"
    t.index ["object_key"], name: "grants_idx1"
    t.index ["owner_id"], name: "grants_idx2"
  end

  create_table "images", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.bigint "base_imagable_id"
    t.string "base_imagable_type"
    t.integer "imagable_id", null: false
    t.string "imagable_type", limit: 64, null: false
    t.string "image", limit: 128, null: false
    t.string "classification"
    t.string "name"
    t.string "description", limit: 254, null: false
    t.boolean "exportable"
    t.string "original_filename", limit: 128, null: false
    t.string "content_type", limit: 128, null: false
    t.integer "file_size", null: false
    t.integer "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["base_imagable_type", "base_imagable_id"], name: "index_images_on_base_imagable_type_and_base_imagable_id"
    t.index ["imagable_id", "imagable_type"], name: "images_idx2"
    t.index ["object_key"], name: "images_idx1"
  end

  create_table "infrastructure_bridge_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "infrastructure_cap_materials", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "infrastructure_chain_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "infrastructure_control_system_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "infrastructure_crossings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "infrastructure_divisions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "organization_id"
    t.boolean "active"
    t.index ["organization_id"], name: "index_infrastructure_divisions_on_organization_id"
  end

  create_table "infrastructure_foundations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "infrastructure_gauge_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "infrastructure_operation_method_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "infrastructure_rail_joinings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "infrastructure_reference_rails", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "infrastructure_segment_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "fta_asset_class_id"
    t.bigint "asset_subtype_id"
    t.string "name"
    t.boolean "active"
    t.index ["asset_subtype_id"], name: "index_infrastructure_segment_types_on_asset_subtype_id"
    t.index ["fta_asset_class_id"], name: "index_infrastructure_segment_types_on_fta_asset_class_id"
  end

  create_table "infrastructure_segment_unit_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "infrastructure_subdivisions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "organization_id"
    t.boolean "active"
    t.index ["organization_id"], name: "index_infrastructure_subdivisions_on_organization_id"
  end

  create_table "infrastructure_tracks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "organization_id"
    t.boolean "active"
    t.index ["organization_id"], name: "index_infrastructure_tracks_on_organization_id"
  end

  create_table "infrastructures", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "from_line"
    t.string "to_line"
    t.bigint "infrastructure_segment_unit_type_id"
    t.decimal "from_segment", precision: 7, scale: 2
    t.decimal "to_segment", precision: 7, scale: 2
    t.string "segment_unit"
    t.string "from_location_name"
    t.string "to_location_name"
    t.bigint "infrastructure_chain_type_id"
    t.decimal "relative_location", precision: 10, scale: 5
    t.string "relative_location_unit"
    t.string "relative_location_direction"
    t.string "location_name"
    t.bigint "infrastructure_segment_type_id"
    t.bigint "infrastructure_division_id"
    t.bigint "infrastructure_subdivision_id"
    t.bigint "infrastructure_track_id"
    t.integer "num_tracks"
    t.string "direction"
    t.bigint "infrastructure_operation_method_type_id"
    t.bigint "infrastructure_control_system_type_id"
    t.bigint "infrastructure_bridge_type_id"
    t.integer "num_spans"
    t.integer "num_decks"
    t.bigint "infrastructure_crossing_id"
    t.bigint "infrastructure_gauge_type_id"
    t.decimal "gauge", precision: 10, scale: 5
    t.string "gauge_unit"
    t.bigint "infrastructure_reference_rail_id"
    t.decimal "track_gradient_pcnt", precision: 10, scale: 5
    t.decimal "track_gradient_degree", precision: 10, scale: 5
    t.decimal "track_gradient", precision: 10, scale: 5
    t.string "track_gradient_unit"
    t.decimal "horizontal_alignment", precision: 10, scale: 5
    t.string "horizontal_alignment_unit"
    t.decimal "vertical_alignment", precision: 10, scale: 5
    t.string "vertical_alignment_unit"
    t.decimal "length", precision: 10, scale: 5
    t.string "length_unit"
    t.decimal "height", precision: 10, scale: 5
    t.string "height_unit"
    t.decimal "width", precision: 10, scale: 5
    t.string "width_unit"
    t.decimal "crosslevel", precision: 10, scale: 5
    t.string "crosslevel_unit"
    t.decimal "warp_parameter", precision: 10, scale: 5
    t.string "warp_parameter_unit"
    t.decimal "track_curvature", precision: 10, scale: 5
    t.string "track_curvature_unit"
    t.decimal "track_curvature_degree", precision: 10, scale: 5
    t.decimal "cant", precision: 10, scale: 5
    t.string "cant_unit"
    t.decimal "cant_gradient", precision: 10, scale: 5
    t.string "cant_gradient_unit"
    t.decimal "max_permissible_speed", precision: 10, scale: 5
    t.string "max_permissible_speed_unit"
    t.string "nearest_city"
    t.string "nearest_state"
    t.bigint "land_ownership_organization_id"
    t.string "other_land_ownership_organization"
    t.bigint "shared_capital_responsibility_organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["infrastructure_bridge_type_id"], name: "index_infrastructures_on_infrastructure_bridge_type_id"
    t.index ["infrastructure_chain_type_id"], name: "index_infrastructures_on_infrastructure_chain_type_id"
    t.index ["infrastructure_control_system_type_id"], name: "index_infrastructures_on_infrastructure_control_system_type_id"
    t.index ["infrastructure_crossing_id"], name: "index_infrastructures_on_infrastructure_crossing_id"
    t.index ["infrastructure_division_id"], name: "index_infrastructures_on_infrastructure_division_id"
    t.index ["infrastructure_gauge_type_id"], name: "index_infrastructures_on_infrastructure_gauge_type_id"
    t.index ["infrastructure_operation_method_type_id"], name: "index_infrastructures_on_infrastructure_operation_method_type_id"
    t.index ["infrastructure_reference_rail_id"], name: "index_infrastructures_on_infrastructure_reference_rail_id"
    t.index ["infrastructure_segment_type_id"], name: "index_infrastructures_on_infrastructure_segment_type_id"
    t.index ["infrastructure_segment_unit_type_id"], name: "index_infrastructures_on_infrastructure_segment_unit_type_id"
    t.index ["infrastructure_subdivision_id"], name: "index_infrastructures_on_infrastructure_subdivision_id"
    t.index ["infrastructure_track_id"], name: "index_infrastructures_on_infrastructure_track_id"
    t.index ["land_ownership_organization_id"], name: "index_infrastructures_on_land_ownership_organization_id"
    t.index ["shared_capital_responsibility_organization_id"], name: "shared_cap_responsibility_org_infrastructure_idx"
  end

  create_table "issue_status_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 32, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active"
  end

  create_table "issue_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "issues", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "issue_type_id", null: false
    t.integer "web_browser_type_id", null: false
    t.integer "created_by_id", null: false
    t.text "comments", null: false
    t.integer "issue_status_type_id"
    t.text "resolution_comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["issue_type_id"], name: "issues_idx2"
    t.index ["object_key"], name: "issues_idx1"
  end

  create_table "keyword_search_indices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_class", limit: 64, null: false
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id", null: false
    t.string "context", limit: 64, null: false
    t.string "summary", limit: 64, null: false
    t.text "search_text", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["object_class"], name: "keyword_search_indices_idx1"
  end

  create_table "leed_certification_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.text "description", limit: 255, null: false
    t.boolean "active", null: false
  end

  create_table "license_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "asset_manager", null: false
    t.boolean "web_services", null: false
    t.boolean "active", null: false
  end

  create_table "location_reference_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "format", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "maintenance_provider_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "code", limit: 2, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "maintenance_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 32, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "manufacturer_models", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "organization_id"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_manufacturer_models_on_organization_id"
  end

  create_table "manufacturers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "filter", limit: 32, null: false
    t.string "name", limit: 128, null: false
    t.string "code", limit: 3, null: false
    t.boolean "active", null: false
    t.index ["filter"], name: "manufacturers_idx1"
  end

  create_table "message_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "message_id"
    t.integer "user_id"
    t.index ["message_id"], name: "message_tags_idx1"
    t.index ["user_id"], name: "message_tags_idx2"
  end

  create_table "messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id", null: false
    t.integer "user_id", null: false
    t.integer "to_user_id"
    t.integer "priority_type_id", null: false
    t.integer "thread_message_id"
    t.string "subject", limit: 64, null: false
    t.text "body"
    t.boolean "active"
    t.datetime "opened_at"
    t.datetime "created_at", null: false
    t.index ["object_key"], name: "messages_idx1"
    t.index ["organization_id"], name: "messages_idx2"
    t.index ["thread_message_id"], name: "messages_idx5"
    t.index ["to_user_id"], name: "messages_idx4"
    t.index ["user_id"], name: "messages_idx3"
  end

  create_table "notice_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.string "display_icon", limit: 64, null: false
    t.string "display_class", limit: 64, null: false
    t.boolean "active"
  end

  create_table "notices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.string "subject", limit: 64, null: false
    t.string "summary", limit: 128, null: false
    t.text "details"
    t.integer "notice_type_id"
    t.integer "organization_id"
    t.datetime "display_datetime"
    t.datetime "end_datetime"
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.string "text", null: false
    t.string "link", null: false
    t.integer "notifiable_id"
    t.string "notifiable_type"
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["notifiable_id", "notifiable_type"], name: "index_notifications_on_notifiable_id_and_notifiable_type"
  end

  create_table "ntd_facilities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "ntd_report_id", null: false
    t.string "facility_id"
    t.string "name", limit: 64, null: false
    t.boolean "part_of_larger_facility"
    t.string "address", limit: 128, null: false
    t.string "city", limit: 64, null: false
    t.string "state", limit: 2, null: false
    t.string "zip", limit: 10, null: false
    t.float "latitude"
    t.float "longitude"
    t.string "primary_mode", limit: 32, null: false
    t.string "secondary_mode"
    t.string "private_mode"
    t.string "facility_type", limit: 32, null: false
    t.integer "year_built", null: false
    t.integer "size", null: false
    t.string "size_type", limit: 32, null: false
    t.integer "pcnt_capital_responsibility", null: false
    t.integer "estimated_cost", null: false
    t.integer "estimated_cost_year", null: false
    t.string "notes", limit: 254
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ntd_report_id"], name: "ntd_admin_and_maintenance_facilities_idx1"
  end

  create_table "ntd_infrastructures", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "ntd_report_id"
    t.string "fta_mode"
    t.string "fta_service_type"
    t.string "fta_type"
    t.integer "size"
    t.integer "linear_miles"
    t.integer "track_miles"
    t.integer "expected_service_life"
    t.integer "pcnt_capital_responsibility"
    t.string "shared_capital_responsibility_organization"
    t.string "description"
    t.string "notes"
    t.string "allocation_unit"
    t.string "pre_nineteen_thirty"
    t.string "nineteen_thirty"
    t.string "nineteen_forty"
    t.string "nineteen_fifty"
    t.string "nineteen_sixty"
    t.string "nineteen_seventy"
    t.string "nineteen_eighty"
    t.string "nineteen_ninety"
    t.string "two_thousand"
    t.string "two_thousand_ten"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ntd_report_id"], name: "index_ntd_infrastructures_on_ntd_report_id"
  end

  create_table "ntd_organization_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ntd_performance_measures", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "ntd_report_id"
    t.bigint "fta_asset_category_id"
    t.string "asset_level"
    t.string "pcnt_goal"
    t.string "pcnt_performance"
    t.integer "future_pcnt_goal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fta_asset_category_id"], name: "index_ntd_performance_measures_on_fta_asset_category_id"
    t.index ["ntd_report_id"], name: "index_ntd_performance_measures_on_ntd_report_id"
  end

  create_table "ntd_reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.bigint "ntd_form_id"
    t.text "processing_log"
    t.string "state"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ntd_form_id"], name: "index_ntd_reports_on_ntd_form_id"
  end

  create_table "ntd_revenue_vehicle_fleets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "ntd_report_id"
    t.string "vehicle_object_key"
    t.string "rvi_id", limit: 32
    t.string "fta_mode"
    t.string "fta_service_type"
    t.string "agency_fleet_id"
    t.string "dedicated"
    t.string "direct_capital_responsibility"
    t.integer "size"
    t.integer "num_active"
    t.integer "num_ada_accessible"
    t.integer "num_emergency_contingency"
    t.string "vehicle_type"
    t.string "manufacture_code"
    t.string "rebuilt_year"
    t.string "model_number"
    t.string "other_manufacturer"
    t.string "fuel_type", limit: 32
    t.string "dual_fuel_type"
    t.integer "vehicle_length"
    t.integer "seating_capacity"
    t.integer "standing_capacity"
    t.integer "total_active_miles_in_period"
    t.integer "avg_lifetime_active_miles"
    t.string "ownership_type"
    t.string "funding_type"
    t.string "notes", limit: 254
    t.string "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "useful_life_remaining", null: false
    t.string "useful_life_benchmark"
    t.integer "manufacture_year", null: false
    t.string "additional_fta_mode"
    t.string "additional_fta_service_type"
    t.string "other_ownership_type"
    t.string "other_fuel_type"
    t.index ["ntd_report_id"], name: "ntd_revenue_vehicle_fleets_idx1"
  end

  create_table "ntd_service_vehicle_fleets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "ntd_report_id"
    t.string "vehicle_object_key"
    t.string "sv_id"
    t.string "fleet_name"
    t.string "agency_fleet_id"
    t.string "name", limit: 64
    t.integer "size"
    t.string "vehicle_type"
    t.string "primary_fta_mode_type"
    t.string "secondary_fta_mode_types"
    t.integer "manufacture_year"
    t.integer "pcnt_capital_responsibility"
    t.integer "estimated_cost"
    t.integer "estimated_cost_year"
    t.string "useful_life_benchmark"
    t.string "useful_life_remaining"
    t.string "notes", limit: 254
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["ntd_report_id"], name: "ntd_service_vehicle_fleets_idx1"
  end

  create_table "organization_role_mappings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "role_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organization_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "class_name", limit: 64, null: false
    t.string "display_icon_name", limit: 64, null: false
    t.string "map_icon_name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.string "roles"
    t.boolean "active", null: false
    t.index ["class_name"], name: "organization_types_idx1"
  end

  create_table "organizations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_type_id", null: false
    t.integer "customer_id", null: false
    t.string "external_id", limit: 32
    t.string "name", limit: 128, null: false
    t.string "short_name", limit: 16, null: false
    t.boolean "license_holder", null: false
    t.string "address1", limit: 128, null: false
    t.string "address2", limit: 128
    t.string "county", limit: 64
    t.string "city", limit: 64, null: false
    t.string "state", limit: 2, null: false
    t.string "zip", limit: 10, null: false
    t.string "phone", limit: 12, null: false
    t.string "phone_ext", limit: 6
    t.string "fax", limit: 12
    t.string "url", limit: 128, null: false
    t.integer "grantor_id"
    t.integer "fta_agency_type_id"
    t.integer "ntd_organization_type_id"
    t.boolean "indian_tribe"
    t.string "subrecipient_number", limit: 9
    t.string "ntd_id_number"
    t.integer "fta_service_area_type_id"
    t.integer "service_area_population"
    t.integer "service_area_size"
    t.string "service_area_size_unit"
    t.string "governing_body", limit: 128
    t.integer "governing_body_type_id"
    t.boolean "active", null: false
    t.decimal "latitude", precision: 11, scale: 6
    t.decimal "longitude", precision: 11, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "organizations_idx2"
    t.index ["grantor_id"], name: "organizations_idx3"
    t.index ["organization_type_id"], name: "organizations_idx1"
    t.index ["short_name"], name: "organizations_idx4"
    t.index ["short_name"], name: "short_name"
  end

  create_table "organizations_districts", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_id"
    t.integer "district_id"
    t.index ["organization_id", "district_id"], name: "organizations_districts_idx2"
  end

  create_table "organizations_saved_queries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "saved_query_id", null: false
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_organizations_saved_queries_on_organization_id"
    t.index ["saved_query_id"], name: "index_organizations_saved_queries_on_saved_query_id"
  end

  create_table "organizations_saved_searches", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_id"
    t.integer "saved_search_id"
    t.index ["organization_id"], name: "index_organizations_saved_searches_on_organization_id"
    t.index ["saved_search_id"], name: "index_organizations_saved_searches_on_saved_search_id"
  end

  create_table "organizations_service_provider_types", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "service_provider_type_id", null: false
    t.index ["organization_id"], name: "organization_spt_idx1"
    t.index ["service_provider_type_id"], name: "organization_spt_idx2"
  end

  create_table "performance_restriction_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "active"
  end

  create_table "planning_partners_organizations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "planning_partner_id"
    t.integer "organization_id"
  end

  create_table "policies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id", null: false
    t.integer "parent_id"
    t.integer "year", null: false
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.integer "depreciation_calculation_type_id", null: false
    t.integer "service_life_calculation_type_id", null: false
    t.integer "cost_calculation_type_id", null: false
    t.integer "condition_estimation_type_id", null: false
    t.integer "depreciation_interval_type_id", null: false
    t.decimal "condition_threshold", precision: 9, scale: 2, null: false
    t.decimal "interest_rate", precision: 9, scale: 2, null: false
    t.boolean "current", null: false
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["object_key"], name: "policies_idx1"
    t.index ["organization_id"], name: "policies_idx2"
  end

  create_table "policy_asset_subtype_rules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "policy_id", null: false
    t.integer "asset_subtype_id", null: false
    t.integer "fuel_type_id"
    t.integer "min_service_life_months", null: false
    t.integer "min_service_life_miles"
    t.integer "replacement_cost", null: false
    t.integer "cost_fy_year", null: false
    t.boolean "replace_with_new", null: false
    t.boolean "replace_with_leased", null: false
    t.integer "replace_asset_subtype_id"
    t.integer "replace_fuel_type_id"
    t.integer "lease_length_months"
    t.integer "rehabilitation_service_month"
    t.integer "rehabilitation_labor_cost"
    t.integer "rehabilitation_parts_cost"
    t.integer "extended_service_life_months"
    t.integer "extended_service_life_miles"
    t.integer "min_used_purchase_service_life_months", null: false
    t.string "purchase_replacement_code", limit: 8, null: false
    t.string "lease_replacement_code", limit: 8
    t.string "purchase_expansion_code", limit: 8
    t.string "lease_expansion_code", limit: 8
    t.string "rehabilitation_code", limit: 8, null: false
    t.string "engineering_design_code", limit: 8
    t.string "construction_code", limit: 8
    t.integer "fta_useful_life_benchmark"
    t.integer "fta_vehicle_type_id"
    t.integer "fta_facility_type_id"
    t.boolean "default_rule"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["asset_subtype_id"], name: "policy_asset_subtype_rules_idx2"
    t.index ["policy_id"], name: "policy_asset_subtype_rules_idx1"
  end

  create_table "policy_asset_type_rules", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "policy_id", null: false
    t.integer "asset_type_id", null: false
    t.integer "service_life_calculation_type_id", null: false
    t.integer "replacement_cost_calculation_type_id", null: false
    t.integer "condition_rollup_calculation_type_id"
    t.decimal "annual_inflation_rate", precision: 9, scale: 2, null: false
    t.integer "pcnt_residual_value", null: false
    t.integer "condition_rollup_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["asset_type_id"], name: "policy_asset_type_rules_idx2"
    t.index ["policy_id"], name: "policy_asset_type_rules_idx1"
  end

  create_table "priority_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "is_default", null: false
    t.boolean "active", null: false
  end

  create_table "query_asset_classes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "table_name"
    t.text "transam_assets_join"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "query_association_classes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "table_name"
    t.string "display_field_name"
    t.string "id_field_name", default: "id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "query_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "query_field_asset_classes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "query_field_id"
    t.bigint "query_asset_class_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["query_asset_class_id"], name: "index_query_field_asset_classes_on_query_asset_class_id"
    t.index ["query_field_id"], name: "index_query_field_asset_classes_on_query_field_id"
  end

  create_table "query_fields", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "query_category_id"
    t.string "filter_type"
    t.bigint "query_association_class_id"
    t.boolean "hidden"
    t.string "pairs_with"
    t.boolean "auto_show"
    t.string "display_field"
    t.string "column_filter"
    t.string "column_filter_value"
    t.index ["query_association_class_id"], name: "index_query_fields_on_query_association_class_id"
    t.index ["query_category_id"], name: "index_query_fields_on_query_category_id"
  end

  create_table "query_filters", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "query_field_id"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "saved_query_id"
    t.string "op"
    t.index ["query_field_id"], name: "index_query_filters_on_query_field_id"
    t.index ["saved_query_id"], name: "index_query_filters_on_saved_query_id"
  end

  create_table "query_params", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.text "query_string"
    t.string "class_name"
    t.boolean "active"
  end

  create_table "ramp_manufacturers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
  end

  create_table "replacement_reason_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active"
  end

  create_table "report_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.string "display_icon_name", limit: 64, null: false
    t.boolean "active", null: false
  end

  create_table "reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "report_type_id", null: false
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.string "class_name", null: false
    t.string "view_name", limit: 32, null: false
    t.string "roles", limit: 128
    t.text "custom_sql"
    t.boolean "show_in_nav"
    t.boolean "show_in_dashboard"
    t.string "chart_type", limit: 32
    t.text "chart_options"
    t.boolean "active", null: false
    t.boolean "printable"
    t.boolean "exportable"
    t.boolean "data_exportable"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_type_id"], name: "reports_idx1"
  end

  create_table "revenue_vehicles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "esl_category_id"
    t.integer "standing_capacity"
    t.bigint "fta_funding_type_id"
    t.bigint "fta_ownership_type_id"
    t.string "other_fta_ownership_type"
    t.boolean "dedicated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["esl_category_id"], name: "index_revenue_vehicles_on_esl_category_id"
    t.index ["fta_funding_type_id"], name: "index_revenue_vehicles_on_fta_funding_type_id"
    t.index ["fta_ownership_type_id"], name: "index_revenue_vehicles_on_fta_ownership_type_id"
  end

  create_table "roles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.integer "weight"
    t.integer "resource_id"
    t.string "resource_type"
    t.integer "role_parent_id"
    t.boolean "show_in_user_mgmt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "privilege", default: false, null: false
    t.string "label"
    t.index ["name"], name: "roles_idx1"
    t.index ["resource_id"], name: "roles_idx2"
  end

  create_table "rule_sets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key"
    t.string "name"
    t.string "class_name"
    t.boolean "rule_set_aware"
    t.boolean "active"
  end

  create_table "saved_queries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key"
    t.string "name"
    t.string "description"
    t.integer "created_by_user_id"
    t.integer "updated_by_user_id"
    t.integer "shared_from_org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "ordered_output_field_ids"
  end

  create_table "saved_query_fields", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "saved_query_id"
    t.bigint "query_field_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["query_field_id"], name: "index_saved_query_fields_on_query_field_id"
    t.index ["saved_query_id"], name: "index_saved_query_fields_on_saved_query_id"
  end

  create_table "saved_searches", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "user_id", null: false
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.integer "search_type_id"
    t.text "json"
    t.text "query_string"
    t.integer "ordinal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "class_name"
    t.boolean "active"
  end

  create_table "serial_numbers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "identifiable_type"
    t.bigint "identifiable_id"
    t.string "identification"
    t.index ["identifiable_type", "identifiable_id"], name: "index_serial_numbers_on_identifiable_type_and_identifiable_id"
  end

  create_table "service_life_calculation_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "class_name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.index ["class_name"], name: "service_life_calculation_types_idx1"
  end

  create_table "service_provider_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "code", limit: 5, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "service_status_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "code", limit: 1, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "service_vehicles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "service_vehiclible_type"
    t.bigint "service_vehiclible_id"
    t.bigint "chassis_id"
    t.string "other_chassis"
    t.bigint "fuel_type_id"
    t.bigint "dual_fuel_type_id"
    t.boolean "fta_emergency_contingency_fleet"
    t.string "other_fuel_type"
    t.string "license_plate"
    t.integer "vehicle_length"
    t.string "vehicle_length_unit"
    t.integer "gross_vehicle_weight"
    t.string "gross_vehicle_weight_unit"
    t.integer "seating_capacity"
    t.integer "wheelchair_capacity"
    t.bigint "ramp_manufacturer_id"
    t.string "other_ramp_manufacturer"
    t.boolean "ada_accessible"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chassis_id"], name: "index_service_vehicles_on_chassis_id"
    t.index ["dual_fuel_type_id"], name: "index_service_vehicles_on_dual_fuel_type_id"
    t.index ["fuel_type_id"], name: "index_service_vehicles_on_fuel_type_id"
    t.index ["ramp_manufacturer_id"], name: "index_service_vehicles_on_ramp_manufacturer_id"
    t.index ["service_vehiclible_type", "service_vehiclible_id"], name: "service_vehiclible_idx"
  end

  create_table "system_config_extensions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "class_name"
    t.string "extension_name"
    t.string "engine_name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "system_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "customer_id"
    t.string "start_of_fiscal_year", limit: 5
    t.string "default_fiscal_year_formatter"
    t.string "default_weather_code"
    t.string "map_tile_provider", limit: 64
    t.integer "srid"
    t.float "min_lat"
    t.float "min_lon"
    t.float "max_lat"
    t.float "max_lon"
    t.integer "search_radius"
    t.string "search_units", limit: 8
    t.string "geocoder_components", limit: 128
    t.string "geocoder_region", limit: 64
    t.integer "num_forecasting_years"
    t.integer "num_reporting_years"
    t.integer "max_rows_returned"
    t.string "special_locked_fields"
    t.string "measurement_system"
    t.string "data_file_path", limit: 64
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tam_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key"
    t.integer "organization_id"
    t.integer "tam_policy_id"
    t.string "name"
    t.integer "leader_id"
    t.integer "parent_id"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_tam_groups_on_organization_id"
    t.index ["tam_policy_id"], name: "index_tam_groups_on_tam_policy_id"
  end

  create_table "tam_groups_fta_asset_categories", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "tam_group_id"
    t.integer "fta_asset_category_id"
  end

  create_table "tam_groups_organizations", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "tam_group_id"
    t.integer "organization_id"
  end

  create_table "tam_performance_metrics", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key"
    t.integer "tam_group_id"
    t.integer "fta_asset_category_id"
    t.string "asset_level_type"
    t.integer "asset_level_id"
    t.integer "parent_id"
    t.integer "useful_life_benchmark"
    t.string "useful_life_benchmark_unit"
    t.boolean "useful_life_benchmark_locked"
    t.integer "pcnt_goal"
    t.boolean "pcnt_goal_locked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tam_group_id"], name: "index_tam_performance_metrics_on_tam_group_id"
  end

  create_table "tam_policies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key"
    t.integer "fy_year"
    t.boolean "copied"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "taskable_id"
    t.string "taskable_type"
    t.integer "user_id", null: false
    t.integer "priority_type_id", null: false
    t.integer "organization_id", null: false
    t.integer "assigned_to_user_id"
    t.string "subject", limit: 64, null: false
    t.text "body", null: false
    t.boolean "send_reminder"
    t.string "state", limit: 32
    t.datetime "complete_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_to_user_id"], name: "tasks_idx5"
    t.index ["complete_by"], name: "tasks_idx6"
    t.index ["object_key"], name: "tasks_idx1"
    t.index ["organization_id"], name: "tasks_idx4"
    t.index ["state"], name: "tasks_idx3"
    t.index ["user_id"], name: "tasks_idx2"
  end

  create_table "team_ali_codes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.string "code", limit: 8
    t.boolean "active"
    t.index ["code"], name: "team_scope_ali_codes_idx3"
    t.index ["name"], name: "team_scope_ali_codes_idx1"
    t.index ["rgt"], name: "team_scope_ali_codes_idx2"
  end

  create_table "transam_assets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "transam_assetible_type"
    t.bigint "transam_assetible_id"
    t.string "object_key", limit: 12, null: false
    t.bigint "organization_id", null: false
    t.bigint "asset_subtype_id"
    t.bigint "upload_id"
    t.string "asset_tag", null: false
    t.date "disposition_date"
    t.string "external_id"
    t.text "description"
    t.bigint "manufacturer_id"
    t.string "other_manufacturer"
    t.bigint "manufacturer_model_id"
    t.string "other_manufacturer_model"
    t.integer "manufacture_year"
    t.integer "quantity"
    t.string "quantity_unit"
    t.integer "purchase_cost"
    t.date "purchase_date"
    t.boolean "purchased_new"
    t.date "in_service_date"
    t.bigint "vendor_id"
    t.string "other_vendor"
    t.integer "parent_id"
    t.integer "location_id"
    t.integer "policy_replacement_year"
    t.integer "scheduled_replacement_year"
    t.integer "scheduled_replacement_cost"
    t.text "early_replacement_reason"
    t.boolean "in_backlog"
    t.boolean "depreciable"
    t.date "depreciation_start_date"
    t.date "current_depreciation_date"
    t.integer "depreciation_useful_life"
    t.integer "depreciation_purchase_cost"
    t.integer "book_value"
    t.integer "salvage_value"
    t.integer "scheduled_rehabilitation_year"
    t.integer "scheduled_disposition_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_subtype_id"], name: "index_transam_assets_on_asset_subtype_id"
    t.index ["manufacturer_id"], name: "index_transam_assets_on_manufacturer_id"
    t.index ["manufacturer_model_id"], name: "index_transam_assets_on_manufacturer_model_id"
    t.index ["organization_id"], name: "index_transam_assets_on_organization_id"
    t.index ["transam_assetible_type", "transam_assetible_id"], name: "transam_assetible_idx"
    t.index ["upload_id"], name: "index_transam_assets_on_upload_id"
    t.index ["vendor_id"], name: "index_transam_assets_on_vendor_id"
  end

  create_table "transit_assets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "transit_assetible_type"
    t.bigint "transit_assetible_id"
    t.bigint "asset_id"
    t.bigint "fta_asset_category_id", null: false
    t.bigint "fta_asset_class_id", null: false
    t.string "fta_type_type", null: false
    t.integer "fta_type_id", null: false
    t.integer "pcnt_capital_responsibility"
    t.string "contract_num"
    t.bigint "contract_type_id"
    t.boolean "has_warranty"
    t.date "warranty_date"
    t.bigint "operator_id"
    t.string "other_operator"
    t.string "title_number"
    t.bigint "title_ownership_organization_id"
    t.string "other_title_ownership_organization"
    t.bigint "lienholder_id"
    t.string "other_lienholder"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_transit_assets_on_asset_id"
    t.index ["contract_type_id"], name: "index_transit_assets_on_contract_type_id"
    t.index ["fta_asset_category_id"], name: "index_transit_assets_on_fta_asset_category_id"
    t.index ["fta_asset_class_id"], name: "index_transit_assets_on_fta_asset_class_id"
    t.index ["fta_type_type", "fta_type_id"], name: "index_transit_assets_on_fta_type_type_and_fta_type_id"
    t.index ["lienholder_id"], name: "index_transit_assets_on_lienholder_id"
    t.index ["operator_id"], name: "index_transit_assets_on_operator_id"
    t.index ["title_ownership_organization_id"], name: "index_transit_assets_on_title_ownership_organization_id"
    t.index ["transit_assetible_type", "transit_assetible_id"], name: "transit_assetible_idx"
  end

  create_table "transit_components", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "component_type_id"
    t.bigint "component_element_type_id"
    t.bigint "component_subtype_id"
    t.bigint "component_material_id"
    t.bigint "infrastructure_rail_joining_id"
    t.integer "infrastructure_measurement"
    t.string "infrastructure_measurement_unit"
    t.integer "infrastructure_weight"
    t.string "infrastructure_weight_unit"
    t.integer "infrastructure_diameter"
    t.string "infrastructure_diameter_unit"
    t.bigint "infrastructure_cap_material_id"
    t.bigint "infrastructure_foundation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_element_type_id"], name: "index_transit_components_on_component_element_type_id"
    t.index ["component_material_id"], name: "index_transit_components_on_component_material_id"
    t.index ["component_subtype_id"], name: "index_transit_components_on_component_subtype_id"
    t.index ["component_type_id"], name: "index_transit_components_on_component_type_id"
    t.index ["infrastructure_cap_material_id"], name: "index_transit_components_on_infrastructure_cap_material_id"
    t.index ["infrastructure_foundation_id"], name: "index_transit_components_on_infrastructure_foundation_id"
    t.index ["infrastructure_rail_joining_id"], name: "index_transit_components_on_infrastructure_rail_joining_id"
  end

  create_table "uploads", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id"
    t.integer "user_id", null: false
    t.integer "file_content_type_id", null: false
    t.integer "file_status_type_id", null: false
    t.string "file", limit: 128, null: false
    t.string "original_filename", limit: 254, null: false
    t.integer "num_rows_processed"
    t.integer "num_rows_added"
    t.integer "num_rows_replaced"
    t.integer "num_rows_skipped"
    t.integer "num_rows_failed"
    t.text "processing_log", limit: 4294967295
    t.boolean "force_update"
    t.datetime "processing_started_at"
    t.datetime "processing_completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["file_content_type_id"], name: "uploads_idx4"
    t.index ["file_status_type_id"], name: "uploads_idx5"
    t.index ["object_key"], name: "uploads_idx1"
    t.index ["organization_id"], name: "uploads_idx2"
    t.index ["user_id"], name: "uploads_idx3"
  end

  create_table "user_notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "notification_id", null: false
    t.datetime "opened_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["notification_id"], name: "index_user_notifications_on_notification_id"
    t.index ["user_id"], name: "index_user_notifications_on_user_id"
  end

  create_table "user_organization_filters", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sort_order"
    t.integer "created_by_user_id"
    t.text "query_string"
    t.integer "resource_id"
    t.string "resource_type"
    t.index ["created_by_user_id"], name: "index_user_organization_filters_on_created_by_user_id"
    t.index ["object_key"], name: "user_organization_filters_idx1"
  end

  create_table "user_organization_filters_organizations", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_organization_filter_id", null: false
    t.integer "organization_id", null: false
    t.index ["user_organization_filter_id", "organization_id"], name: "user_organization_filters_idx1"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id", null: false
    t.string "external_id", limit: 32
    t.string "first_name", limit: 64, null: false
    t.string "last_name", limit: 64, null: false
    t.string "title", limit: 64
    t.string "phone", limit: 12, null: false
    t.string "phone_ext", limit: 6
    t.string "timezone", limit: 32, null: false
    t.string "email", limit: 128, null: false
    t.string "address1", limit: 64
    t.string "address2", limit: 64
    t.string "city", limit: 32
    t.string "state", limit: 2
    t.string "zip", limit: 10
    t.integer "num_table_rows"
    t.integer "user_organization_filter_id"
    t.string "encrypted_password", limit: 64, null: false
    t.string "reset_password_token", limit: 64
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 16
    t.string "last_sign_in_ip", limit: 16
    t.integer "failed_attempts", null: false
    t.string "unlock_token", limit: 128
    t.datetime "locked_at"
    t.boolean "notify_via_email", null: false
    t.integer "weather_code_id"
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "authentication_token", limit: 30
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "users_idx3"
    t.index ["object_key"], name: "users_idx1"
    t.index ["organization_id"], name: "users_idx2"
  end

  create_table "users_organizations", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
    t.index ["user_id", "organization_id"], name: "users_organizations_idx2"
  end

  create_table "users_roles", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
    t.integer "granted_by_user_id"
    t.date "granted_on_date"
    t.integer "revoked_by_user_id"
    t.date "revoked_on_date"
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["active"], name: "users_roles_idx3"
    t.index ["user_id", "role_id"], name: "users_roles_idx2"
  end

  create_table "users_user_organization_filters", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "user_organization_filter_id", null: false
    t.index ["user_id"], name: "users_user_organization_filters_idx1"
    t.index ["user_organization_filter_id"], name: "users_user_organization_filters_idx2"
  end

  create_table "users_viewable_organizations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
  end

  create_table "vehicle_features", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "code", limit: 3, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "vehicle_rebuild_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.text "description", limit: 255, null: false
    t.boolean "active", null: false
  end

  create_table "vehicle_storage_method_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "code", limit: 1, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "vehicle_usage_codes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "code", limit: 1, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "vendors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "organization_id", null: false
    t.string "name", limit: 64, null: false
    t.string "address1", limit: 64
    t.string "address2", limit: 64
    t.string "city", limit: 64
    t.string "state", limit: 2
    t.string "zip", limit: 10
    t.string "phone", limit: 12
    t.string "phone_ext", limit: 6
    t.string "fax", limit: 12
    t.string "url", limit: 128
    t.decimal "latitude", precision: 11, scale: 6
    t.decimal "longitude", precision: 11, scale: 6
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "vendors_idx2"
    t.index ["object_key"], name: "vendors_idx1"
    t.index ["organization_id"], name: "vendors_idx3"
  end

  create_table "versions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
  end

  create_table "weather_codes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "state", limit: 2
    t.string "code", limit: 8
    t.string "city", limit: 64
    t.boolean "active"
    t.index ["state", "city"], name: "weather_codes_idx"
  end

  create_table "web_browser_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.string "description", limit: 254, null: false
    t.boolean "active", null: false
  end

  create_table "workflow_events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "object_key", limit: 12, null: false
    t.integer "accountable_id", null: false
    t.string "accountable_type", limit: 64, null: false
    t.string "event_type", limit: 64, null: false
    t.integer "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["accountable_id", "accountable_type"], name: "workflow_events_idx2"
    t.index ["object_key"], name: "workflow_events_idx1"
  end

  add_foreign_key "query_field_asset_classes", "query_asset_classes"
  add_foreign_key "query_field_asset_classes", "query_fields"
  add_foreign_key "query_filters", "query_fields"
  add_foreign_key "saved_query_fields", "query_fields"
  add_foreign_key "saved_query_fields", "saved_queries"
end
