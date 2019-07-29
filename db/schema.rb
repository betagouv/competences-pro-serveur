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

ActiveRecord::Schema.define(version: 2019_07_29_084304) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "campagnes", force: :cascade do |t|
    t.string "libelle"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "questionnaire_id"
    t.bigint "compte_id"
    t.index ["compte_id"], name: "index_campagnes_on_compte_id"
    t.index ["questionnaire_id"], name: "index_campagnes_on_questionnaire_id"
  end

  create_table "choix", force: :cascade do |t|
    t.string "intitule"
    t.bigint "question_id"
    t.integer "type_choix"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["question_id"], name: "index_choix_on_question_id"
  end

  create_table "comptes", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.index ["email"], name: "index_comptes_on_email", unique: true
    t.index ["reset_password_token"], name: "index_comptes_on_reset_password_token", unique: true
  end

  create_table "evaluations", force: :cascade do |t|
    t.string "nom"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "campagne_id"
    t.index ["campagne_id"], name: "index_evaluations_on_campagne_id"
  end

  create_table "evenements", force: :cascade do |t|
    t.string "nom"
    t.jsonb "donnees", default: {}, null: false
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "session_id"
    t.bigint "situation_id"
    t.bigint "evaluation_id"
    t.index ["evaluation_id"], name: "index_evenements_on_evaluation_id"
    t.index ["situation_id"], name: "index_evenements_on_situation_id"
  end

  create_table "questionnaires", force: :cascade do |t|
    t.string "libelle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questionnaires_questions", force: :cascade do |t|
    t.bigint "questionnaire_id"
    t.bigint "question_id"
    t.integer "position"
    t.index ["question_id"], name: "index_questionnaires_questions_on_question_id"
    t.index ["questionnaire_id"], name: "index_questionnaires_questions_on_questionnaire_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "intitule"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.string "description"
    t.string "entete_reponse"
    t.string "expediteur"
    t.string "message"
    t.string "objet_reponse"
    t.string "libelle"
  end

  create_table "situations", force: :cascade do |t|
    t.string "libelle"
    t.string "nom_technique"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "situations_configurations", force: :cascade do |t|
    t.bigint "campagne_id"
    t.bigint "situation_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campagne_id"], name: "index_situations_configurations_on_campagne_id"
    t.index ["situation_id"], name: "index_situations_configurations_on_situation_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "campagnes", "comptes"
  add_foreign_key "campagnes", "questionnaires"
  add_foreign_key "choix", "questions"
  add_foreign_key "evaluations", "campagnes"
  add_foreign_key "evenements", "situations"
  add_foreign_key "questionnaires_questions", "questionnaires"
  add_foreign_key "questionnaires_questions", "questions"
end
