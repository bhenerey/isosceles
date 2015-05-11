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

ActiveRecord::Schema.define(version: 20150427152231) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.integer  "node_id"
    t.datetime "event_date"
    t.text     "event_message"
    t.integer  "event_status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nodes", force: :cascade do |t|
    t.string   "ec2_id",                     limit: 255
    t.string   "ec2_name",                   limit: 255
    t.string   "ec2_private_ip",             limit: 255
    t.string   "ec2_availability_zone",      limit: 255
    t.string   "ec2_state",                  limit: 255
    t.string   "aws_tag_environment",        limit: 255
    t.string   "aws_tag_apps",               limit: 255
    t.string   "chef_runlist",               limit: 255
    t.string   "sensu_client_name",          limit: 255
    t.string   "sensu_client_subscriptions", limit: 255
    t.text     "sensu_checks"
    t.integer  "events_count",                           default: 0
    t.integer  "sensu_events_count",                     default: 0
    t.integer  "sensu_stashes_count",                    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "iso_client_ip"
    t.text     "sensu_client_address"
    t.integer  "sensu_checks_count"
    t.string   "chef_bootstrapped",          limit: 255
    t.string   "chef_name",                  limit: 255
    t.string   "chef_env",                   limit: 255
    t.string   "chef_uptime",                limit: 255, default: "Unknown"
    t.string   "chef_version",               limit: 255, default: "Unknown"
    t.string   "chef_platform",              limit: 255, default: "Unknown"
    t.integer  "chef_last_ohai"
    t.integer  "newrelic_id"
    t.text     "newrelic_name"
    t.text     "newrelic_host"
    t.text     "newrelic_health_status"
    t.text     "newrelic_last_reported_at"
    t.boolean  "newrelic_reporting"
    t.integer  "sensu_timestamp"
    t.text     "xen_name"
    t.text     "xen_power_state"
    t.text     "xen_last_shutdown_time"
  end

  add_index "nodes", ["ec2_private_ip"], name: "index_nodes_on_ec2_private_ip", using: :btree

  create_table "sensu_checks", force: :cascade do |t|
    t.integer  "node_id"
    t.text     "name"
    t.integer  "interval"
    t.boolean  "standalone"
    t.text     "timeout"
    t.text     "handlers"
    t.text     "subscribers"
    t.text     "command"
    t.text     "check_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sensu_events", force: :cascade do |t|
    t.integer  "node_id"
    t.datetime "date"
    t.text     "output"
    t.integer  "status",              limit: 2
    t.text     "handlers"
    t.integer  "occurrences"
    t.text     "client"
    t.text     "check"
    t.text     "event_id"
    t.text     "status_name"
    t.text     "url"
    t.text     "client_silence_path"
    t.text     "silence_path"
    t.boolean  "client_silenced"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sensu_stashes", force: :cascade do |t|
    t.integer  "node_id"
    t.text     "path"
    t.integer  "stash_timestamp"
    t.text     "expire"
    t.text     "reason"
    t.text     "full_content"
    t.text     "silence_path"
    t.text     "client_silence_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
