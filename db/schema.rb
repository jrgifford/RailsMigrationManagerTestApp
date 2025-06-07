# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 0) do
  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.string "color", default: "#6B7280"
    t.integer "posts_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "categories_posts", id: false, force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "category_id", null: false
    t.index ["category_id"], name: "index_categories_posts_on_category_id"
    t.index ["post_id", "category_id"], name: "index_categories_posts_on_post_id_and_category_id", unique: true
    t.index ["post_id"], name: "index_categories_posts_on_post_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content", null: false
    t.integer "post_id", null: false
    t.integer "user_id", null: false
    t.integer "parent_id"
    t.boolean "approved", default: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_comments_on_created_at"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["post_id", "approved"], name: "index_comments_on_post_id_and_approved"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title", null: false
    t.text "content"
    t.boolean "published", default: false
    t.integer "user_id", null: false
    t.integer "view_count", default: 0
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comments_count", default: 0
    t.boolean "featured", default: false
    t.text "tags"
    t.index ["featured"], name: "index_posts_on_featured"
    t.index ["published"], name: "index_posts_on_published"
    t.index ["user_id", "published"], name: "index_posts_on_user_id_and_published"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "skipped_migrations", force: :cascade do |t|
    t.string "version"
    t.string "filename"
    t.datetime "skipped_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user"
    t.boolean "active", default: true
    t.text "bio"
    t.string "avatar_url"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name"
  end

  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "posts", "users"
end
