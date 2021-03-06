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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131018063812) do

  create_table "askapatients", :force => true do |t|
    t.string   "name"
    t.string   "source_id"
    t.integer  "current_reviews"
    t.integer  "latest_reviews"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "commonconditions", :force => true do |t|
    t.string   "name"
    t.integer  "condition_id"
    t.string   "category"
    t.string   "remarks"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "commondrugs", :force => true do |t|
    t.string   "brand_name"
    t.integer  "drug_id"
    t.string   "druglabels"
    t.string   "conditions"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "conditioninfographs", :force => true do |t|
    t.integer  "condition_id"
    t.string   "most_reviewed"
    t.float    "cheapest"
    t.string   "most_satisfied"
    t.string   "most_kids_using"
    t.float    "total_reviews"
    t.string   "top_side_effect"
    t.string   "most_easy_to_use"
    t.string   "most_effective"
    t.string   "overall_winner"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "most_bad_reviews"
  end

  create_table "conditionmetrics", :force => true do |t|
    t.string   "condition"
    t.string   "drug"
    t.float    "eff"
    t.float    "sat"
    t.float    "eou"
    t.integer  "eff_bad"
    t.integer  "eff_avg"
    t.integer  "eff_good"
    t.integer  "sat_bad"
    t.integer  "sat_avg"
    t.integer  "sat_good"
    t.integer  "eou_bad"
    t.integer  "eou_avg"
    t.integer  "eou_good"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "conditions", :force => true do |t|
    t.text     "information"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.string   "name"
    t.string   "symptoms"
    t.string   "causes"
    t.string   "risk_factors"
    t.string   "treatment_and_medication"
    t.string   "prevention"
    t.string   "other_names"
    t.string   "alternative_medication"
    t.string   "complications"
    t.string   "lifestyle"
    t.string   "coping_with_disease"
  end

  create_table "conditions_metric", :force => true do |t|
    t.string   "condition"
    t.string   "drug"
    t.float    "eff"
    t.float    "sat"
    t.float    "eou"
    t.integer  "eff_bad"
    t.integer  "eff_avg"
    t.integer  "eff_good"
    t.integer  "sat_bad"
    t.integer  "sat_avg"
    t.integer  "sat_good"
    t.integer  "eou_bad"
    t.integer  "eou_avg"
    t.integer  "eou_good"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "druginfographs", :force => true do |t|
    t.string   "brand_name"
    t.float    "avg_sat_male"
    t.float    "avg_sat_female"
    t.string   "top_used_words"
    t.float    "age_more_50"
    t.float    "age_less_18"
    t.float    "age_btw_18_50"
    t.float    "no_of_males"
    t.float    "no_of_females"
    t.float    "effective_over_3"
    t.float    "effective_less_3"
    t.float    "eou_over_3"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.float    "eou_less_3"
  end

  create_table "drugs", :force => true do |t|
    t.string   "generic_name"
    t.string   "brand_name"
    t.string   "side_effect"
    t.text     "dosage"
    t.text     "precaution"
    t.string   "manufacturer"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "source_id"
    t.integer  "reviews_count",      :default => 0
    t.string   "other_names"
    t.string   "prescription_for"
    t.string   "how_to_use"
    t.string   "other_uses"
    t.string   "dietary_precaution"
    t.string   "storage"
    t.string   "other_info"
    t.string   "other_known_names"
  end

  create_table "everydayhealths", :force => true do |t|
    t.string   "name"
    t.string   "source_id"
    t.integer  "current_reviews"
    t.integer  "latest_reviews"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "mostcommondrugs", :force => true do |t|
    t.string   "brand_name"
    t.integer  "count"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "drug_id"
  end

  create_table "reviews", :force => true do |t|
    t.integer  "drug_id"
    t.integer  "user_id"
    t.text     "comments",                             :null => false
    t.string   "review_url"
    t.float    "effectiveness",                        :null => false
    t.float    "ease_of_use",                          :null => false
    t.float    "satisfactory",                         :null => false
    t.float    "tolerability",        :default => 0.0
    t.string   "tag_cloud_path"
    t.integer  "similar_experience",  :default => 0
    t.integer  "usage_duration_days"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "other_drugs"
    t.string   "source"
  end

  create_table "searches", :force => true do |t|
    t.string   "keyword"
    t.string   "gender"
    t.string   "age"
    t.string   "location"
    t.string   "ethnicity"
    t.integer  "weight"
    t.string   "smoking_status"
    t.string   "new"
    t.string   "show"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "drug_name"
  end

  create_table "tags", :force => true do |t|
    t.string   "brand_name"
    t.string   "word_list"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "treatments", :force => true do |t|
    t.integer  "drug_id"
    t.integer  "condition_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "treatments", ["condition_id"], :name => "index_treatments_on_condition_id"
  add_index "treatments", ["drug_id"], :name => "index_treatments_on_drug_id"

  create_table "users", :force => true do |t|
    t.string   "username",                          :null => false
    t.string   "age",                               :null => false
    t.string   "ethnicity"
    t.string   "email_address"
    t.string   "location"
    t.string   "gender",                            :null => false
    t.string   "ip_address"
    t.string   "genome_file"
    t.integer  "weight"
    t.string   "smoking_status"
    t.boolean  "allow_contact",  :default => true
    t.boolean  "caregiver",      :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "webmds", :force => true do |t|
    t.string   "brand_name"
    t.string   "source_id"
    t.integer  "current_reviews"
    t.integer  "latest_reviews"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

end
