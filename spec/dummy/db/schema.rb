# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20161014201011) do

  create_table "activities", force: true do |t|
    t.string   "object_key",           limit: 12
    t.integer  "organization_type_id"
    t.string   "name",                 limit: 64
    t.text     "description"
    t.boolean  "show_in_dashboard"
    t.boolean  "system_activity"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "frequency_quantity",              null: false
    t.integer  "frequency_type_id",               null: false
    t.string   "execution_time",       limit: 32, null: false
    t.string   "job_name",             limit: 64
    t.datetime "last_run"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activity_logs", force: true do |t|
    t.integer  "organization_id",                    null: false
    t.string   "item_type",       limit: 64,         null: false
    t.integer  "item_id"
    t.integer  "user_id",                            null: false
    t.text     "activity",        limit: 2147483647, null: false
    t.datetime "activity_time"
  end

  add_index "activity_logs", ["organization_id", "activity_time"], name: "activity_logs_idx1", using: :btree
  add_index "activity_logs", ["user_id", "activity_time"], name: "activity_logs_idx2", using: :btree

  create_table "asset_event_asset_subsystems", force: true do |t|
    t.integer "asset_event_id"
    t.integer "asset_subsystem_id"
    t.integer "parts_cost"
    t.integer "labor_cost"
  end

  add_index "asset_event_asset_subsystems", ["asset_event_id"], name: "rehab_events_subsystems_idx1", using: :btree
  add_index "asset_event_asset_subsystems", ["asset_subsystem_id"], name: "rehab_events_subsystems_idx2", using: :btree

  create_table "asset_event_types", force: true do |t|
    t.string  "name",              limit: 64,  null: false
    t.string  "class_name",        limit: 64,  null: false
    t.string  "job_name",          limit: 64,  null: false
    t.string  "display_icon_name", limit: 64,  null: false
    t.string  "description",       limit: 254, null: false
    t.boolean "active",                        null: false
  end

  add_index "asset_event_types", ["class_name"], name: "asset_event_types_idx1", using: :btree

  create_table "asset_events", force: true do |t|
    t.string   "object_key",                     limit: 12,                          null: false
    t.integer  "asset_id",                                                           null: false
    t.integer  "asset_event_type_id",                                                null: false
    t.integer  "upload_id"
    t.date     "event_date",                                                         null: false
    t.decimal  "assessed_rating",                            precision: 9, scale: 2
    t.integer  "condition_type_id"
    t.integer  "current_mileage"
    t.integer  "parent_id"
    t.integer  "replacement_year"
    t.integer  "rebuild_year"
    t.integer  "disposition_year"
    t.integer  "extended_useful_life_miles"
    t.integer  "extended_useful_life_months"
    t.integer  "replacement_reason_type_id"
    t.date     "disposition_date"
    t.integer  "disposition_type_id"
    t.integer  "service_status_type_id"
    t.integer  "maintenance_type_id"
    t.integer  "pcnt_5311_routes"
    t.integer  "avg_daily_use_hours"
    t.integer  "avg_daily_use_miles"
    t.integer  "avg_daily_passenger_trips"
    t.integer  "maintenance_provider_type_id"
    t.integer  "vehicle_storage_method_type_id"
    t.decimal  "avg_cost_per_mile",                          precision: 9, scale: 2
    t.decimal  "avg_miles_per_gallon",                       precision: 9, scale: 2
    t.integer  "annual_maintenance_cost"
    t.integer  "annual_insurance_cost"
    t.boolean  "actual_costs"
    t.integer  "annual_affected_ridership"
    t.integer  "annual_dollars_generated"
    t.integer  "sales_proceeds"
    t.text     "comments"
    t.integer  "organization_id"
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
    t.string   "state",                          limit: 32
    t.string   "document",                       limit: 128
    t.string   "original_filename",              limit: 128
    t.integer  "created_by_id"
  end

  add_index "asset_events", ["asset_event_type_id"], name: "asset_events_idx3", using: :btree
  add_index "asset_events", ["asset_id"], name: "asset_events_idx2", using: :btree
  add_index "asset_events", ["created_by_id"], name: "asset_events_creator_idx", using: :btree
  add_index "asset_events", ["event_date"], name: "asset_events_idx4", using: :btree
  add_index "asset_events", ["object_key"], name: "asset_events_idx1", using: :btree
  add_index "asset_events", ["upload_id"], name: "asset_events_idx5", using: :btree

  create_table "asset_events_vehicle_usage_codes", id: false, force: true do |t|
    t.integer "asset_event_id"
    t.integer "vehicle_usage_code_id"
  end

  add_index "asset_events_vehicle_usage_codes", ["asset_event_id", "vehicle_usage_code_id"], name: "asset_events_vehicle_usage_codes_idx1", using: :btree

  create_table "asset_groups", force: true do |t|
    t.string   "object_key",      limit: 12,  null: false
    t.integer  "organization_id",             null: false
    t.string   "name",            limit: 64,  null: false
    t.string   "code",            limit: 8,   null: false
    t.string   "description",     limit: 254
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "asset_groups", ["object_key"], name: "asset_groups_idx1", using: :btree
  add_index "asset_groups", ["organization_id"], name: "asset_groups_idx2", using: :btree

  create_table "asset_groups_assets", id: false, force: true do |t|
    t.integer "asset_id",       null: false
    t.integer "asset_group_id", null: false
  end

  add_index "asset_groups_assets", ["asset_id", "asset_group_id"], name: "asset_groups_assets_idx1", using: :btree

  create_table "asset_subsystems", force: true do |t|
    t.string  "name",          limit: 64
    t.string  "code",          limit: 2
    t.string  "description",   limit: 254
    t.integer "asset_type_id"
    t.boolean "active"
  end

  create_table "asset_subtypes", force: true do |t|
    t.integer "asset_type_id",             null: false
    t.string  "name",          limit: 64,  null: false
    t.string  "description",   limit: 254, null: false
    t.string  "image",         limit: 254
    t.boolean "active",                    null: false
  end

  add_index "asset_subtypes", ["asset_type_id"], name: "asset_subtypes_idx1", using: :btree

  create_table "asset_tags", force: true do |t|
    t.integer "asset_id"
    t.integer "user_id"
  end

  add_index "asset_tags", ["asset_id"], name: "asset_tags_idx1", using: :btree
  add_index "asset_tags", ["user_id"], name: "asset_tags_idx2", using: :btree

  create_table "asset_types", force: true do |t|
    t.string  "name",              limit: 64,  null: false
    t.string  "class_name",        limit: 64,  null: false
    t.string  "display_icon_name", limit: 64,  null: false
    t.string  "map_icon_name",     limit: 64,  null: false
    t.string  "description",       limit: 254, null: false
    t.boolean "active",                        null: false
  end

  add_index "asset_types", ["class_name"], name: "asset_types_idx1", using: :btree
  add_index "asset_types", ["name"], name: "asset_types_idx2", using: :btree

  create_table "asset_types_manufacturers", id: false, force: true do |t|
    t.integer "asset_type_id"
    t.integer "manufacturer_id"
  end

  add_index "asset_types_manufacturers", ["asset_type_id", "manufacturer_id"], name: "asset_types_manufacturers_idx1", using: :btree

  create_table "assets", force: true do |t|
    t.string   "object_key",                         limit: 12,                           null: false
    t.integer  "organization_id",                                                         null: false
    t.integer  "asset_type_id",                                                           null: false
    t.integer  "asset_subtype_id",                                                        null: false
    t.string   "asset_tag",                          limit: 32,                           null: false
    t.string   "external_id",                        limit: 32
    t.integer  "parent_id"
    t.integer  "superseded_by_id"
    t.integer  "manufacturer_id"
    t.string   "manufacturer_model",                 limit: 128
    t.integer  "manufacture_year"
    t.integer  "pcnt_capital_responsibility"
    t.integer  "vendor_id"
    t.integer  "policy_replacement_year"
    t.integer  "policy_rehabilitation_year"
    t.integer  "estimated_replacement_year"
    t.integer  "estimated_replacement_cost"
    t.integer  "scheduled_replacement_year"
    t.integer  "scheduled_rehabilitation_year"
    t.integer  "scheduled_disposition_year"
    t.integer  "scheduled_replacement_cost"
    t.text     "early_replacement_reason"
    t.boolean  "scheduled_replace_with_new"
    t.integer  "scheduled_rehabilitation_cost"
    t.integer  "replacement_reason_type_id"
    t.boolean  "in_backlog"
    t.integer  "reported_condition_type_id"
    t.decimal  "reported_condition_rating",                      precision: 10, scale: 1
    t.integer  "reported_mileage"
    t.date     "reported_condition_date"
    t.integer  "estimated_condition_type_id"
    t.decimal  "estimated_condition_rating",                     precision: 9,  scale: 2
    t.integer  "service_status_type_id"
    t.date     "service_status_date"
    t.date     "last_maintenance_date"
    t.boolean  "depreciable"
    t.date     "depreciation_start_date"
    t.date     "current_depreciation_date"
    t.integer  "book_value"
    t.integer  "salvage_value"
    t.date     "disposition_date"
    t.integer  "disposition_type_id"
    t.date     "last_rehabilitation_date"
    t.integer  "maintenance_provider_type_id"
    t.integer  "vehicle_storage_method_type_id"
    t.integer  "vehicle_rebuild_type_id"
    t.integer  "location_reference_type_id"
    t.string   "location_reference",                 limit: 254
    t.text     "location_comments"
    t.integer  "fuel_type_id"
    t.integer  "vehicle_length"
    t.integer  "gross_vehicle_weight"
    t.string   "title_number",                       limit: 32
    t.integer  "title_owner_organization_id"
    t.string   "serial_number",                      limit: 32
    t.boolean  "purchased_new"
    t.integer  "purchase_cost"
    t.date     "purchase_date"
    t.date     "warranty_date"
    t.date     "in_service_date"
    t.integer  "expected_useful_life"
    t.integer  "expected_useful_miles"
    t.integer  "purchase_method_type_id"
    t.integer  "rebuild_year"
    t.string   "license_plate",                      limit: 32
    t.integer  "seating_capacity"
    t.integer  "standing_capacity"
    t.integer  "wheelchair_capacity"
    t.integer  "fta_ownership_type_id"
    t.integer  "fta_vehicle_type_id"
    t.integer  "fta_funding_type_id"
    t.integer  "fta_bus_mode_type_id"
    t.boolean  "ada_accessible_lift"
    t.boolean  "ada_accessible_ramp"
    t.boolean  "fta_emergency_contingency_fleet"
    t.string   "description",                        limit: 128
    t.string   "address1",                           limit: 128
    t.string   "address2",                           limit: 128
    t.string   "city",                               limit: 64
    t.string   "state",                              limit: 2
    t.string   "zip",                                limit: 10
    t.integer  "facility_size"
    t.boolean  "section_of_larger_facility"
    t.integer  "pcnt_operational"
    t.integer  "num_floors"
    t.integer  "num_structures"
    t.integer  "num_elevators"
    t.integer  "num_escalators"
    t.integer  "num_parking_spaces_public"
    t.integer  "num_parking_spaces_private"
    t.decimal  "lot_size",                                       precision: 9,  scale: 2
    t.string   "line_number",                        limit: 128
    t.integer  "land_ownership_type_id"
    t.integer  "land_ownership_organization_id"
    t.integer  "building_ownership_type_id"
    t.integer  "building_ownership_organization_id"
    t.integer  "facility_capacity_type_id"
    t.integer  "fta_facility_type_id"
    t.integer  "leed_certification_type_id"
    t.integer  "quantity"
    t.string   "quantity_units",                     limit: 16
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.integer  "upload_id"
  end

  add_index "assets", ["asset_subtype_id"], name: "assets_idx4", using: :btree
  add_index "assets", ["asset_type_id"], name: "assets_idx3", using: :btree
  add_index "assets", ["estimated_replacement_year"], name: "assets_idx8", using: :btree
  add_index "assets", ["in_backlog"], name: "assets_idx7", using: :btree
  add_index "assets", ["manufacture_year"], name: "assets_idx5", using: :btree
  add_index "assets", ["object_key"], name: "assets_idx1", using: :btree
  add_index "assets", ["organization_id", "asset_subtype_id", "in_backlog"], name: "assets_idx12", using: :btree
  add_index "assets", ["organization_id", "asset_subtype_id", "policy_replacement_year"], name: "assets_idx10", using: :btree
  add_index "assets", ["organization_id", "in_backlog"], name: "assets_idx11", using: :btree
  add_index "assets", ["organization_id", "policy_replacement_year"], name: "assets_idx9", using: :btree
  add_index "assets", ["organization_id"], name: "assets_idx2", using: :btree
  add_index "assets", ["reported_condition_type_id"], name: "assets_idx6", using: :btree
  add_index "assets", ["superseded_by_id"], name: "assets_idx13", using: :btree

  create_table "assets_districts", id: false, force: true do |t|
    t.integer "asset_id"
    t.integer "district_id"
  end

  add_index "assets_districts", ["asset_id", "district_id"], name: "assets_districts_idx1", using: :btree

  create_table "assets_expenditures", id: false, force: true do |t|
    t.integer "asset_id",       null: false
    t.integer "expenditure_id", null: false
  end

  add_index "assets_expenditures", ["asset_id", "expenditure_id"], name: "assets_expenditures_idx1", using: :btree

  create_table "assets_facility_features", id: false, force: true do |t|
    t.integer "asset_id",            null: false
    t.integer "facility_feature_id", null: false
  end

  add_index "assets_facility_features", ["asset_id", "facility_feature_id"], name: "assets_facility_features_idx1", using: :btree

  create_table "assets_fta_mode_types", id: false, force: true do |t|
    t.integer "asset_id"
    t.integer "fta_mode_type_id"
  end

  add_index "assets_fta_mode_types", ["asset_id", "fta_mode_type_id"], name: "assets_fta_mode_types_idx1", using: :btree

  create_table "assets_fta_service_types", id: false, force: true do |t|
    t.integer "asset_id"
    t.integer "fta_service_type_id"
  end

  add_index "assets_fta_service_types", ["asset_id", "fta_service_type_id"], name: "assets_fta_service_types_idx1", using: :btree

  create_table "assets_general_ledger_accounts", id: false, force: true do |t|
    t.integer "asset_id",                  null: false
    t.integer "general_ledger_account_id", null: false
  end

  add_index "assets_general_ledger_accounts", ["asset_id", "general_ledger_account_id"], name: "assets_general_ledger_accounts_idx1", using: :btree

  create_table "assets_usage_codes", id: false, force: true do |t|
    t.integer "asset_id"
    t.integer "usage_code_id"
  end

  add_index "assets_usage_codes", ["asset_id", "usage_code_id"], name: "assets_usage_codes_idx1", using: :btree

  create_table "assets_vehicle_features", id: false, force: true do |t|
    t.integer "asset_id"
    t.integer "vehicle_feature_id"
  end

  add_index "assets_vehicle_features", ["asset_id", "vehicle_feature_id"], name: "assets_vehicle_features_idx1", using: :btree

  create_table "assets_vehicle_usage_codes", id: false, force: true do |t|
    t.integer "asset_id",              null: false
    t.integer "vehicle_usage_code_id", null: false
  end

  add_index "assets_vehicle_usage_codes", ["asset_id", "vehicle_usage_code_id"], name: "assets_vehicle_usage_codes_idx1", using: :btree

  create_table "budget_amounts", force: true do |t|
    t.string   "object_key",        limit: 12, null: false
    t.integer  "organization_id",              null: false
    t.integer  "funding_source_id",            null: false
    t.integer  "fy_year",                      null: false
    t.integer  "amount",                       null: false
    t.boolean  "estimated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "budget_amounts", ["object_key"], name: "budget_amounts_idx1", using: :btree
  add_index "budget_amounts", ["organization_id", "funding_source_id", "fy_year"], name: "budget_amounts_idx2", using: :btree

  create_table "chart_of_accounts", force: true do |t|
    t.string   "object_key",      limit: 12
    t.integer  "organization_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chart_of_accounts", ["organization_id"], name: "chart_of_accounts_idx1", using: :btree

  create_table "comments", force: true do |t|
    t.string   "object_key",       limit: 12,  null: false
    t.integer  "commentable_id",               null: false
    t.string   "commentable_type", limit: 64,  null: false
    t.string   "comment",          limit: 254, null: false
    t.integer  "created_by_id",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "comments_idx1", using: :btree

  create_table "condition_estimation_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "class_name",  limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  add_index "condition_estimation_types", ["class_name"], name: "condition_estimation_types_idx1", using: :btree

  create_table "condition_types", force: true do |t|
    t.string  "name",        limit: 64,                          null: false
    t.decimal "rating",                  precision: 9, scale: 2, null: false
    t.string  "description", limit: 254,                         null: false
    t.boolean "active",                                          null: false
  end

  create_table "cost_calculation_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "class_name",  limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  add_index "cost_calculation_types", ["class_name"], name: "cost_calculation_types_idx1", using: :btree

  create_table "customers", force: true do |t|
    t.integer  "license_type_id",            null: false
    t.string   "name",            limit: 64, null: false
    t.boolean  "active",                     null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority"
    t.integer  "attempts"
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "depreciation_calculation_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "class_name",  limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "depreciation_interval_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.integer "months",                  null: false
    t.boolean "active",                  null: false
  end

  create_table "disposition_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 2,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "district_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "districts", force: true do |t|
    t.integer "district_type_id",             null: false
    t.string  "name",             limit: 64,  null: false
    t.string  "code",             limit: 6,   null: false
    t.string  "description",      limit: 254, null: false
    t.boolean "active",                       null: false
  end

  add_index "districts", ["district_type_id"], name: "districts_idx1", using: :btree
  add_index "districts", ["name"], name: "districts_idx2", using: :btree

  create_table "documents", force: true do |t|
    t.string   "object_key",        limit: 12,  null: false
    t.integer  "documentable_id",               null: false
    t.string   "documentable_type", limit: 64,  null: false
    t.string   "document",          limit: 128, null: false
    t.string   "description",       limit: 254, null: false
    t.string   "original_filename", limit: 128, null: false
    t.string   "content_type",      limit: 128, null: false
    t.integer  "file_size",                     null: false
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "documents", ["documentable_id", "documentable_type"], name: "documents_idx2", using: :btree
  add_index "documents", ["object_key"], name: "documents_idx1", using: :btree

  create_table "expenditures", force: true do |t|
    t.string   "object_key",                limit: 12,  null: false
    t.integer  "organization_id",                       null: false
    t.integer  "vendor_id"
    t.integer  "general_ledger_account_id"
    t.integer  "grant_id"
    t.integer  "expense_type_id",                       null: false
    t.string   "external_id",               limit: 32
    t.date     "expense_date",                          null: false
    t.string   "description",               limit: 254
    t.integer  "amount",                                null: false
    t.integer  "pcnt_from_grant"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "expenditures", ["expense_type_id"], name: "expenditures_idx4", using: :btree
  add_index "expenditures", ["general_ledger_account_id"], name: "expenditures_idx3", using: :btree
  add_index "expenditures", ["object_key"], name: "expenditures_idx1", using: :btree
  add_index "expenditures", ["organization_id"], name: "expenditures_idx2", using: :btree

  create_table "expense_types", force: true do |t|
    t.integer "organization_id",             null: false
    t.string  "name",            limit: 64,  null: false
    t.string  "description",     limit: 254, null: false
    t.boolean "active",                      null: false
  end

  add_index "expense_types", ["name"], name: "expense_types_idx2", using: :btree
  add_index "expense_types", ["organization_id"], name: "expense_types_idx1", using: :btree

  create_table "facility_capacity_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "facility_features", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 4,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active"
  end

  create_table "file_content_types", force: true do |t|
    t.string  "name",         limit: 64,  null: false
    t.string  "class_name",   limit: 64,  null: false
    t.string  "builder_name"
    t.string  "description",  limit: 254, null: false
    t.boolean "active",                   null: false
  end

  add_index "file_content_types", ["class_name"], name: "file_content_types_idx2", using: :btree
  add_index "file_content_types", ["name"], name: "file_content_types_idx1", using: :btree

  create_table "file_status_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  add_index "file_status_types", ["name"], name: "file_status_types_idx1", using: :btree

  create_table "forms", force: true do |t|
    t.string   "object_key",  limit: 12,  null: false
    t.string   "name",        limit: 64,  null: false
    t.string   "description", limit: 254, null: false
    t.string   "roles",       limit: 128, null: false
    t.string   "controller",  limit: 64,  null: false
    t.boolean  "active",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "forms", ["object_key"], name: "forms_idx1", using: :btree

  create_table "frequency_types", force: true do |t|
    t.string  "name",        limit: 32,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "fta_agency_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 256, null: false
    t.boolean "active",                  null: false
  end

  create_table "fta_bus_mode_types", force: true do |t|
    t.string  "code",        limit: 4,   null: false
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "fta_facility_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "fta_funding_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 4,   null: false
    t.string  "description", limit: 256, null: false
    t.boolean "active",                  null: false
  end

  create_table "fta_mode_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 2,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "fta_mode_types_organizations", id: false, force: true do |t|
    t.integer "organization_id",  null: false
    t.integer "fta_mode_type_id", null: false
  end

  add_index "fta_mode_types_organizations", ["organization_id", "fta_mode_type_id"], name: "fta_mode_types_organizations_idx1", using: :btree

  create_table "fta_ownership_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 4,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "fta_service_area_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "fta_service_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 2,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "fta_vehicle_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 2,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "fuel_types", force: true do |t|
    t.string  "name",        null: false
    t.string  "code",        null: false
    t.string  "description", null: false
    t.boolean "active",      null: false
  end

  create_table "funding_bucket_types", force: true do |t|
    t.string  "name",        null: false
    t.string  "description", null: false
    t.boolean "active",      null: false
  end

  create_table "funding_buckets", force: true do |t|
    t.string   "object_key",          limit: 12,                          null: false
    t.integer  "funding_template_id",                                     null: false
    t.integer  "fiscal_year",                                             null: false
    t.decimal  "budget_amount",                  precision: 15, scale: 2, null: false
    t.decimal  "budget_committed",               precision: 15, scale: 2, null: false
    t.integer  "owner_id"
    t.string   "description"
    t.boolean  "active",                                                  null: false
    t.integer  "created_by_id",                                           null: false
    t.datetime "created_on"
    t.integer  "updated_by_id",                                           null: false
    t.datetime "updated_on"
  end

  create_table "funding_source_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "funding_sources", force: true do |t|
    t.string   "object_key",             limit: 12,  null: false
    t.string   "name",                   limit: 64,  null: false
    t.string   "description",            limit: 256, null: false
    t.text     "details"
    t.integer  "funding_source_type_id",             null: false
    t.string   "external_id",            limit: 32
    t.boolean  "formula_fund"
    t.boolean  "discretionary_fund"
    t.float    "match_required",         limit: 24
    t.integer  "fy_start"
    t.integer  "fy_end"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "inflation_rate",         limit: 24
    t.integer  "life_in_years"
  end

  add_index "funding_sources", ["object_key"], name: "funding_sources_idx1", using: :btree

  create_table "funding_template_types", force: true do |t|
    t.integer "funding_source_id"
    t.string  "name",              limit: 64,  null: false
    t.string  "description",       limit: 256, null: false
    t.boolean "active",                        null: false
  end

  add_index "funding_template_types", ["funding_source_id"], name: "index_funding_template_types_on_funding_source_id", using: :btree

  create_table "funding_templates", force: true do |t|
    t.string   "object_key",        limit: 12, null: false
    t.integer  "funding_source_id"
    t.string   "name",              limit: 64, null: false
    t.text     "description"
    t.integer  "contributor_id",               null: false
    t.integer  "owner_id",                     null: false
    t.boolean  "recurring"
    t.boolean  "transfer_only"
    t.float    "match_required",    limit: 24
    t.text     "query_string"
    t.boolean  "active",                       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "external_id",       limit: 32
  end

  add_index "funding_templates", ["contributor_id"], name: "index_funding_templates_on_contributor_id", using: :btree
  add_index "funding_templates", ["funding_source_id"], name: "index_funding_templates_on_funding_source_id", using: :btree
  add_index "funding_templates", ["owner_id"], name: "index_funding_templates_on_owner_id", using: :btree

  create_table "funding_templates_funding_template_types", id: false, force: true do |t|
    t.integer "funding_template_id"
    t.integer "funding_template_type_id"
  end

  add_index "funding_templates_funding_template_types", ["funding_template_id"], name: "funding_templates_funding_template_types_idx1", using: :btree
  add_index "funding_templates_funding_template_types", ["funding_template_type_id"], name: "funding_templates_funding_template_types_idx2", using: :btree

  create_table "funding_templates_organizations", id: false, force: true do |t|
    t.integer "funding_template_id"
    t.integer "organization_id"
  end

  add_index "funding_templates_organizations", ["funding_template_id"], name: "index_funding_templates_organizations_on_funding_template_id", using: :btree
  add_index "funding_templates_organizations", ["organization_id"], name: "index_funding_templates_organizations_on_organization_id", using: :btree

  create_table "general_ledger_account_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "general_ledger_accounts", force: true do |t|
    t.string   "object_key",                     limit: 12, null: false
    t.integer  "chart_of_account_id",                       null: false
    t.integer  "general_ledger_account_type_id",            null: false
    t.string   "account_number",                 limit: 32, null: false
    t.string   "name",                           limit: 64, null: false
    t.boolean  "active",                                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "general_ledger_accounts", ["active"], name: "general_ledger_accounts_idx3", using: :btree
  add_index "general_ledger_accounts", ["chart_of_account_id"], name: "general_ledger_accounts_idx2", using: :btree
  add_index "general_ledger_accounts", ["object_key"], name: "general_ledger_accounts_idx1", using: :btree

  create_table "governing_body_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "grant_budgets", force: true do |t|
    t.integer "general_ledger_account_id", null: false
    t.integer "grant_id",                  null: false
    t.integer "amount",                    null: false
  end

  add_index "grant_budgets", ["general_ledger_account_id", "grant_id"], name: "grant_budgets_idx1", using: :btree

  create_table "grant_purchases", force: true do |t|
    t.integer  "asset_id",           null: false
    t.integer  "grant_id",           null: false
    t.integer  "pcnt_purchase_cost", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grant_purchases", ["asset_id", "grant_id"], name: "grant_purchases_idx1", using: :btree

  create_table "grants", force: true do |t|
    t.string   "object_key",        limit: 12, null: false
    t.integer  "organization_id",              null: false
    t.integer  "funding_source_id",            null: false
    t.integer  "fy_year",                      null: false
    t.string   "grant_number",      limit: 64, null: false
    t.integer  "amount",                       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grants", ["funding_source_id"], name: "grants_idx4", using: :btree
  add_index "grants", ["fy_year"], name: "grants_idx3", using: :btree
  add_index "grants", ["object_key"], name: "grants_idx1", using: :btree
  add_index "grants", ["organization_id"], name: "grants_idx2", using: :btree

  create_table "images", force: true do |t|
    t.string   "object_key",        limit: 12,  null: false
    t.integer  "imagable_id",                   null: false
    t.string   "imagable_type",     limit: 64,  null: false
    t.string   "image",             limit: 128, null: false
    t.string   "description",       limit: 254, null: false
    t.string   "original_filename", limit: 128, null: false
    t.string   "content_type",      limit: 128, null: false
    t.integer  "file_size",                     null: false
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["imagable_id", "imagable_type"], name: "images_idx2", using: :btree
  add_index "images", ["object_key"], name: "images_idx1", using: :btree

  create_table "issue_status_types", force: true do |t|
    t.string  "name",        limit: 32,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active"
  end

  create_table "issue_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "issues", force: true do |t|
    t.string   "object_key",           limit: 12, null: false
    t.integer  "issue_type_id",                   null: false
    t.integer  "web_browser_type_id",             null: false
    t.integer  "created_by_id",                   null: false
    t.text     "comments",                        null: false
    t.integer  "issue_status_type_id"
    t.text     "resolution_comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issues", ["issue_type_id"], name: "issues_idx2", using: :btree
  add_index "issues", ["object_key"], name: "issues_idx1", using: :btree

  create_table "keyword_search_indices", force: true do |t|
    t.string   "object_class",    limit: 64, null: false
    t.string   "object_key",      limit: 12, null: false
    t.integer  "organization_id",            null: false
    t.string   "context",         limit: 64, null: false
    t.string   "summary",         limit: 64, null: false
    t.text     "search_text",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "keyword_search_indices", ["object_class"], name: "keyword_search_indices_idx1", using: :btree

  create_table "leed_certification_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.text    "description", limit: 255, null: false
    t.boolean "active",                  null: false
  end

  create_table "license_types", force: true do |t|
    t.string  "name",          limit: 64,  null: false
    t.string  "description",   limit: 254, null: false
    t.boolean "asset_manager",             null: false
    t.boolean "web_services",              null: false
    t.boolean "active",                    null: false
  end

  create_table "location_reference_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "format",      limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "maintenance_provider_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 2,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "maintenance_types", force: true do |t|
    t.string  "name",        limit: 32,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "manufacturers", force: true do |t|
    t.string  "filter", limit: 32,  null: false
    t.string  "name",   limit: 128, null: false
    t.string  "code",   limit: 3,   null: false
    t.boolean "active",             null: false
  end

  add_index "manufacturers", ["filter"], name: "manufacturers_idx1", using: :btree

  create_table "message_tags", force: true do |t|
    t.integer "message_id"
    t.integer "user_id"
  end

  add_index "message_tags", ["message_id"], name: "message_tags_idx1", using: :btree
  add_index "message_tags", ["user_id"], name: "message_tags_idx2", using: :btree

  create_table "messages", force: true do |t|
    t.string   "object_key",        limit: 12, null: false
    t.integer  "organization_id",              null: false
    t.integer  "user_id",                      null: false
    t.integer  "to_user_id"
    t.integer  "priority_type_id",             null: false
    t.integer  "thread_message_id"
    t.string   "subject",           limit: 64, null: false
    t.text     "body"
    t.boolean  "active"
    t.datetime "opened_at"
    t.datetime "created_at",                   null: false
  end

  add_index "messages", ["object_key"], name: "messages_idx1", using: :btree
  add_index "messages", ["organization_id"], name: "messages_idx2", using: :btree
  add_index "messages", ["thread_message_id"], name: "messages_idx5", using: :btree
  add_index "messages", ["to_user_id"], name: "messages_idx4", using: :btree
  add_index "messages", ["user_id"], name: "messages_idx3", using: :btree

  create_table "notice_types", force: true do |t|
    t.string  "name",          limit: 64,  null: false
    t.string  "description",   limit: 254, null: false
    t.string  "display_icon",  limit: 64,  null: false
    t.string  "display_class", limit: 64,  null: false
    t.boolean "active"
  end

  create_table "notices", force: true do |t|
    t.string   "object_key",       limit: 12,  null: false
    t.string   "subject",          limit: 64,  null: false
    t.string   "summary",          limit: 128, null: false
    t.text     "details"
    t.integer  "notice_type_id"
    t.integer  "organization_id"
    t.datetime "display_datetime"
    t.datetime "end_datetime"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: true do |t|
    t.string   "object_key",      limit: 12, null: false
    t.string   "text",                       null: false
    t.string   "link",                       null: false
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["notifiable_id", "notifiable_type"], name: "index_notifications_on_notifiable_id_and_notifiable_type", using: :btree

  create_table "organization_types", force: true do |t|
    t.string  "name",              limit: 64,  null: false
    t.string  "class_name",        limit: 64,  null: false
    t.string  "display_icon_name", limit: 64,  null: false
    t.string  "map_icon_name",     limit: 64,  null: false
    t.string  "description",       limit: 254, null: false
    t.boolean "active",                        null: false
  end

  add_index "organization_types", ["class_name"], name: "organization_types_idx1", using: :btree

  create_table "organizations", force: true do |t|
    t.integer  "organization_type_id",                                          null: false
    t.integer  "customer_id",                                                   null: false
    t.string   "external_id",              limit: 32
    t.string   "name",                     limit: 128,                          null: false
    t.string   "short_name",               limit: 16,                           null: false
    t.boolean  "license_holder",                                                null: false
    t.string   "address1",                 limit: 128,                          null: false
    t.string   "address2",                 limit: 128
    t.string   "county",                   limit: 64
    t.string   "city",                     limit: 64,                           null: false
    t.string   "state",                    limit: 2,                            null: false
    t.string   "zip",                      limit: 10,                           null: false
    t.string   "phone",                    limit: 12,                           null: false
    t.string   "phone_ext",                limit: 6
    t.string   "fax",                      limit: 10
    t.string   "url",                      limit: 128,                          null: false
    t.integer  "grantor_id"
    t.integer  "fta_agency_type_id"
    t.boolean  "indian_tribe"
    t.string   "subrecipient_number",      limit: 9
    t.string   "ntd_id_number",            limit: 4
    t.integer  "fta_service_area_type_id"
    t.string   "governing_body",           limit: 128
    t.integer  "governing_body_type_id"
    t.boolean  "active",                                                        null: false
    t.decimal  "latitude",                             precision: 11, scale: 6
    t.decimal  "longitude",                            precision: 11, scale: 6
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
  end

  add_index "organizations", ["customer_id"], name: "organizations_idx2", using: :btree
  add_index "organizations", ["grantor_id"], name: "organizations_idx3", using: :btree
  add_index "organizations", ["organization_type_id"], name: "organizations_idx1", using: :btree
  add_index "organizations", ["short_name"], name: "organizations_idx4", using: :btree
  add_index "organizations", ["short_name"], name: "short_name", using: :btree

  create_table "organizations_districts", id: false, force: true do |t|
    t.integer "organization_id"
    t.integer "district_id"
  end

  add_index "organizations_districts", ["organization_id", "district_id"], name: "organizations_districts_idx2", using: :btree

  create_table "organizations_service_provider_types", id: false, force: true do |t|
    t.integer "organization_id",          null: false
    t.integer "service_provider_type_id", null: false
  end

  add_index "organizations_service_provider_types", ["organization_id"], name: "organization_spt_idx1", using: :btree
  add_index "organizations_service_provider_types", ["service_provider_type_id"], name: "organization_spt_idx2", using: :btree

  create_table "policies", force: true do |t|
    t.string   "object_key",                       limit: 12,                          null: false
    t.integer  "organization_id",                                                      null: false
    t.integer  "parent_id"
    t.integer  "year",                                                                 null: false
    t.string   "name",                             limit: 64,                          null: false
    t.string   "description",                      limit: 254,                         null: false
    t.integer  "depreciation_calculation_type_id",                                     null: false
    t.integer  "service_life_calculation_type_id",                                     null: false
    t.integer  "cost_calculation_type_id",                                             null: false
    t.integer  "condition_estimation_type_id",                                         null: false
    t.integer  "depreciation_interval_type_id",                                        null: false
    t.decimal  "condition_threshold",                          precision: 9, scale: 2, null: false
    t.decimal  "interest_rate",                                precision: 9, scale: 2, null: false
    t.boolean  "current",                                                              null: false
    t.boolean  "active",                                                               null: false
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
  end

  add_index "policies", ["object_key"], name: "policies_idx1", using: :btree
  add_index "policies", ["organization_id"], name: "policies_idx2", using: :btree

  create_table "policy_asset_subtype_rules", force: true do |t|
    t.integer  "policy_id",                                       null: false
    t.integer  "asset_subtype_id",                                null: false
    t.integer  "fuel_type_id"
    t.integer  "min_service_life_months",                         null: false
    t.integer  "min_service_life_miles"
    t.integer  "replacement_cost",                                null: false
    t.integer  "cost_fy_year",                                    null: false
    t.boolean  "replace_with_new",                                null: false
    t.boolean  "replace_with_leased",                             null: false
    t.integer  "replace_asset_subtype_id"
    t.integer  "replace_fuel_type_id"
    t.integer  "lease_length_months"
    t.integer  "rehabilitation_service_month"
    t.integer  "rehabilitation_labor_cost"
    t.integer  "rehabilitation_parts_cost"
    t.integer  "extended_service_life_months"
    t.integer  "extended_service_life_miles"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "min_used_purchase_service_life_months",           null: false
    t.string   "purchase_replacement_code",             limit: 8, null: false
    t.string   "lease_replacement_code",                limit: 8
    t.string   "purchase_expansion_code",               limit: 8
    t.string   "lease_expansion_code",                  limit: 8
    t.string   "rehabilitation_code",                   limit: 8, null: false
    t.string   "engineering_design_code",               limit: 8
    t.string   "construction_code",                     limit: 8
    t.boolean  "default_rule"
  end

  add_index "policy_asset_subtype_rules", ["asset_subtype_id"], name: "policy_asset_subtype_rules_idx2", using: :btree
  add_index "policy_asset_subtype_rules", ["policy_id"], name: "policy_asset_subtype_rules_idx1", using: :btree

  create_table "policy_asset_type_rules", force: true do |t|
    t.integer  "policy_id",                                                    null: false
    t.integer  "asset_type_id",                                                null: false
    t.integer  "service_life_calculation_type_id",                             null: false
    t.integer  "replacement_cost_calculation_type_id",                         null: false
    t.decimal  "annual_inflation_rate",                precision: 9, scale: 2, null: false
    t.integer  "pcnt_residual_value",                                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "policy_asset_type_rules", ["asset_type_id"], name: "policy_asset_type_rules_idx2", using: :btree
  add_index "policy_asset_type_rules", ["policy_id"], name: "policy_asset_type_rules_idx1", using: :btree

  create_table "priority_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "is_default",              null: false
    t.boolean "active",                  null: false
  end

  create_table "purchase_method_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 2,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "replacement_reason_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active"
  end

  create_table "report_types", force: true do |t|
    t.string  "name",              limit: 64,  null: false
    t.string  "description",       limit: 254, null: false
    t.string  "display_icon_name", limit: 64,  null: false
    t.boolean "active",                        null: false
  end

  create_table "reports", force: true do |t|
    t.integer  "report_type_id",                null: false
    t.string   "name",              limit: 64,  null: false
    t.string   "description",       limit: 254, null: false
    t.string   "class_name",        limit: 32,  null: false
    t.string   "view_name",         limit: 32,  null: false
    t.string   "roles",             limit: 128
    t.text     "custom_sql"
    t.boolean  "show_in_nav"
    t.boolean  "show_in_dashboard"
    t.string   "chart_type",        limit: 32
    t.text     "chart_options"
    t.boolean  "active",                        null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "reports", ["report_type_id"], name: "reports_idx1", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name",          limit: 64,                 null: false
    t.integer  "weight"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "privilege",                default: false, null: false
  end

  add_index "roles", ["name"], name: "roles_idx1", using: :btree
  add_index "roles", ["resource_id"], name: "roles_idx2", using: :btree

  create_table "service_life_calculation_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "class_name",  limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  add_index "service_life_calculation_types", ["class_name"], name: "service_life_calculation_types_idx1", using: :btree

  create_table "service_provider_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 5,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "service_status_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 1,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "system_configs", force: true do |t|
    t.integer  "customer_id"
    t.string   "start_of_fiscal_year",  limit: 5
    t.string   "map_tile_provider",     limit: 64
    t.integer  "srid"
    t.float    "min_lat",               limit: 24
    t.float    "min_lon",               limit: 24
    t.float    "max_lat",               limit: 24
    t.float    "max_lon",               limit: 24
    t.integer  "search_radius"
    t.string   "search_units",          limit: 8
    t.string   "geocoder_components",   limit: 128
    t.string   "geocoder_region",       limit: 64
    t.integer  "num_forecasting_years"
    t.integer  "num_reporting_years"
    t.string   "asset_base_class_name", limit: 64
    t.integer  "max_rows_returned"
    t.string   "data_file_path",        limit: 64
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", force: true do |t|
    t.string   "object_key",          limit: 12, null: false
    t.integer  "taskable_id"
    t.string   "taskable_type"
    t.integer  "user_id",                        null: false
    t.integer  "priority_type_id",               null: false
    t.integer  "organization_id",                null: false
    t.integer  "assigned_to_user_id"
    t.string   "subject",             limit: 64, null: false
    t.text     "body",                           null: false
    t.boolean  "send_reminder"
    t.string   "state",               limit: 32
    t.datetime "complete_by",                    null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "tasks", ["assigned_to_user_id"], name: "tasks_idx5", using: :btree
  add_index "tasks", ["complete_by"], name: "tasks_idx6", using: :btree
  add_index "tasks", ["object_key"], name: "tasks_idx1", using: :btree
  add_index "tasks", ["organization_id"], name: "tasks_idx4", using: :btree
  add_index "tasks", ["state"], name: "tasks_idx3", using: :btree
  add_index "tasks", ["user_id"], name: "tasks_idx2", using: :btree

  create_table "team_ali_codes", force: true do |t|
    t.string  "name",      limit: 64
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.string  "code",      limit: 8
    t.boolean "active"
  end

  add_index "team_ali_codes", ["code"], name: "team_scope_ali_codes_idx3", using: :btree
  add_index "team_ali_codes", ["name"], name: "team_scope_ali_codes_idx1", using: :btree
  add_index "team_ali_codes", ["rgt"], name: "team_scope_ali_codes_idx2", using: :btree

  create_table "uploads", force: true do |t|
    t.string   "object_key",              limit: 12,         null: false
    t.integer  "organization_id"
    t.integer  "user_id",                                    null: false
    t.integer  "file_content_type_id",                       null: false
    t.integer  "file_status_type_id",                        null: false
    t.string   "file",                    limit: 128,        null: false
    t.string   "original_filename",       limit: 254,        null: false
    t.integer  "num_rows_processed"
    t.integer  "num_rows_added"
    t.integer  "num_rows_replaced"
    t.integer  "num_rows_skipped"
    t.integer  "num_rows_failed"
    t.text     "processing_log",          limit: 2147483647
    t.boolean  "force_update"
    t.datetime "processing_started_at"
    t.datetime "processing_completed_at"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "uploads", ["file_content_type_id"], name: "uploads_idx4", using: :btree
  add_index "uploads", ["file_status_type_id"], name: "uploads_idx5", using: :btree
  add_index "uploads", ["object_key"], name: "uploads_idx1", using: :btree
  add_index "uploads", ["organization_id"], name: "uploads_idx2", using: :btree
  add_index "uploads", ["user_id"], name: "uploads_idx3", using: :btree

  create_table "user_notifications", force: true do |t|
    t.integer  "user_id",         null: false
    t.integer  "notification_id", null: false
    t.datetime "opened_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_notifications", ["notification_id"], name: "index_user_notifications_on_notification_id", using: :btree
  add_index "user_notifications", ["user_id"], name: "index_user_notifications_on_user_id", using: :btree

  create_table "user_organization_filters", force: true do |t|
    t.string   "object_key",  limit: 12,  null: false
    t.integer  "user_id",                 null: false
    t.string   "name",        limit: 64,  null: false
    t.string   "description", limit: 254, null: false
    t.boolean  "active",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order"
  end

  add_index "user_organization_filters", ["object_key"], name: "user_organization_filters_idx1", using: :btree
  add_index "user_organization_filters", ["user_id"], name: "user_organization_filters_idx2", using: :btree

  create_table "user_organization_filters_organizations", id: false, force: true do |t|
    t.integer "user_organization_filter_id", null: false
    t.integer "organization_id",             null: false
  end

  add_index "user_organization_filters_organizations", ["user_organization_filter_id", "organization_id"], name: "user_organization_filters_idx1", using: :btree

  create_table "users", force: true do |t|
    t.string   "object_key",                  limit: 12,  null: false
    t.integer  "organization_id",                         null: false
    t.string   "external_id",                 limit: 32
    t.string   "first_name",                  limit: 64,  null: false
    t.string   "last_name",                   limit: 64,  null: false
    t.string   "title",                       limit: 64
    t.string   "phone",                       limit: 12,  null: false
    t.string   "phone_ext",                   limit: 6
    t.string   "timezone",                    limit: 32,  null: false
    t.string   "email",                       limit: 128, null: false
    t.string   "address1",                    limit: 64
    t.string   "address2",                    limit: 64
    t.string   "city",                        limit: 32
    t.string   "state",                       limit: 2
    t.string   "zip",                         limit: 10
    t.integer  "num_table_rows"
    t.integer  "user_organization_filter_id"
    t.string   "encrypted_password",          limit: 64,  null: false
    t.string   "reset_password_token",        limit: 64
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",          limit: 16
    t.string   "last_sign_in_ip",             limit: 16
    t.integer  "failed_attempts",                         null: false
    t.string   "unlock_token",                limit: 128
    t.datetime "locked_at"
    t.boolean  "notify_via_email",                        null: false
    t.integer  "weather_code_id"
    t.boolean  "active",                                  null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "users", ["email"], name: "users_idx3", using: :btree
  add_index "users", ["object_key"], name: "users_idx1", using: :btree
  add_index "users", ["organization_id"], name: "users_idx2", using: :btree

  create_table "users_organizations", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "organization_id"
  end

  add_index "users_organizations", ["user_id", "organization_id"], name: "users_organizations_idx2", using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer  "user_id",            null: false
    t.integer  "role_id",            null: false
    t.integer  "granted_by_user_id"
    t.date     "granted_on_date"
    t.integer  "revoked_by_user_id"
    t.date     "revoked_on_date"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users_roles", ["active"], name: "users_roles_idx3", using: :btree
  add_index "users_roles", ["user_id", "role_id"], name: "users_roles_idx2", using: :btree

  create_table "vehicle_features", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 3,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "vehicle_rebuild_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.text    "description", limit: 255, null: false
    t.boolean "active",                  null: false
  end

  create_table "vehicle_storage_method_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 1,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "vehicle_usage_codes", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "code",        limit: 1,   null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "vendors", force: true do |t|
    t.string   "object_key",      limit: 12,                           null: false
    t.integer  "organization_id",                                      null: false
    t.string   "name",            limit: 64,                           null: false
    t.string   "address1",        limit: 64
    t.string   "address2",        limit: 64
    t.string   "city",            limit: 64
    t.string   "state",           limit: 2
    t.string   "zip",             limit: 10
    t.string   "phone",           limit: 12
    t.string   "phone_ext",       limit: 6
    t.string   "fax",             limit: 12
    t.string   "url",             limit: 128
    t.decimal  "latitude",                    precision: 11, scale: 6
    t.decimal  "longitude",                   precision: 11, scale: 6
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vendors", ["name"], name: "vendors_idx2", using: :btree
  add_index "vendors", ["object_key"], name: "vendors_idx1", using: :btree
  add_index "vendors", ["organization_id"], name: "vendors_idx3", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  create_table "weather_codes", force: true do |t|
    t.string  "state",  limit: 2
    t.string  "code",   limit: 8
    t.string  "city",   limit: 64
    t.boolean "active"
  end

  add_index "weather_codes", ["state", "city"], name: "weather_codes_idx", using: :btree

  create_table "web_browser_types", force: true do |t|
    t.string  "name",        limit: 64,  null: false
    t.string  "description", limit: 254, null: false
    t.boolean "active",                  null: false
  end

  create_table "workflow_events", force: true do |t|
    t.string   "object_key",       limit: 12, null: false
    t.integer  "accountable_id",              null: false
    t.string   "accountable_type", limit: 64, null: false
    t.string   "event_type",       limit: 64, null: false
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_events", ["accountable_id", "accountable_type"], name: "workflow_events_idx2", using: :btree
  add_index "workflow_events", ["object_key"], name: "workflow_events_idx1", using: :btree

end
