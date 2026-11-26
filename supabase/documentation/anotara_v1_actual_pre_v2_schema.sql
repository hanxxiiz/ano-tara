


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."email_exists"("p_email" "text") RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public', 'auth'
    AS $$
  select exists (
    select 1 from auth.users
    where lower(email) = lower(trim(p_email))
  );
$$;


ALTER FUNCTION "public"."email_exists"("p_email" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."email_status"("p_email" "text") RETURNS "text"
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public', 'auth'
    AS $$
  select coalesce(
    (
      select case
        when email_confirmed_at is not null then 'verified'
        else 'unverified'
      end
      from auth.users
      where lower(email) = lower(trim(p_email))
      limit 1
    ),
    'not_found'
  );
$$;


ALTER FUNCTION "public"."email_status"("p_email" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_group_usual_free_days"("target_group_id" "uuid") RETURNS TABLE("user_id" "uuid", "usual_free_days" "text"[])
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select mp.user_id, mp.usual_free_days
  from public.member_preferences mp
  join public.group_members owner_members
    on owner_members.group_id = target_group_id
   and owner_members.user_id = mp.user_id
   and owner_members.status = 'active'
  join public.groups shared_group
    on shared_group.id = target_group_id
   and shared_group.archived_at is null
  where exists (
    select 1
    from public.group_members viewer_members
    where viewer_members.group_id = target_group_id
      and viewer_members.user_id = auth.uid()
      and viewer_members.status = 'active'
  )
  order by mp.user_id;
$$;


ALTER FUNCTION "public"."get_group_usual_free_days"("target_group_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
begin
  insert into public.profiles (id, first_name, last_name, username)
  values (
    new.id,
    new.raw_user_meta_data ->> 'first_name',
    new.raw_user_meta_data ->> 'last_name',
    lower(new.raw_user_meta_data ->> 'username')
  );
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_group_admin"("target_group_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select exists (
    select 1
    from public.group_members gm
    where gm.group_id = target_group_id
      and gm.user_id = auth.uid()
      and gm.status = 'active'
      and gm.role = 'organizer'
  );
$$;


ALTER FUNCTION "public"."is_group_admin"("target_group_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_group_member"("target_group_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select exists (
    select 1
    from public.group_members gm
    where gm.group_id = target_group_id
      and gm.user_id = auth.uid()
      and gm.status = 'active'
  );
$$;


ALTER FUNCTION "public"."is_group_member"("target_group_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_trip_member"("target_trip_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  select exists (
    select 1
    from public.trip_members tm
    where tm.trip_id = target_trip_id
      and tm.user_id = auth.uid()
      and tm.response <> 'not_going'
  );
$$;


ALTER FUNCTION "public"."is_trip_member"("target_trip_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."username_available"("p_username" "text") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
  select not exists (
    select 1 from public.profiles where lower(username) = lower(p_username)
  );
$$;


ALTER FUNCTION "public"."username_available"("p_username" "text") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."expense_shares" (
    "expense_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "share_amount" numeric(12,2) NOT NULL,
    "share_value" numeric(12,4),
    "is_settled" boolean DEFAULT false NOT NULL,
    "settled_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "expense_shares_share_amount_check" CHECK (("share_amount" >= (0)::numeric))
);


ALTER TABLE "public"."expense_shares" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."expenses" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "trip_id" "uuid" NOT NULL,
    "paid_by" "uuid" NOT NULL,
    "created_by" "uuid" NOT NULL,
    "description" "text" NOT NULL,
    "amount" numeric(12,2) NOT NULL,
    "currency" character(3) DEFAULT 'PHP'::"bpchar" NOT NULL,
    "category" "text",
    "occurred_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "split_method" "text" DEFAULT 'equal'::"text" NOT NULL,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "expenses_amount_check" CHECK (("amount" > (0)::numeric)),
    CONSTRAINT "expenses_split_method_check" CHECK (("split_method" = ANY (ARRAY['equal'::"text", 'custom'::"text", 'percentage'::"text", 'shares'::"text"])))
);


ALTER TABLE "public"."expenses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."group_invitations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "group_id" "uuid" NOT NULL,
    "inviter_id" "uuid" NOT NULL,
    "invitee_user_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "token_hash" "text",
    "expires_at" timestamp with time zone DEFAULT ("timezone"('utc'::"text", "now"()) + '7 days'::interval) NOT NULL,
    "accepted_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "group_invitations_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'accepted'::"text", 'declined'::"text", 'expired'::"text", 'cancelled'::"text"])))
);


ALTER TABLE "public"."group_invitations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."group_members" (
    "group_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "text" DEFAULT 'member'::"text" NOT NULL,
    "status" "text" DEFAULT 'active'::"text" NOT NULL,
    "joined_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "group_members_role_check" CHECK (("role" = ANY (ARRAY['organizer'::"text", 'member'::"text"]))),
    CONSTRAINT "group_members_status_check" CHECK (("status" = ANY (ARRAY['active'::"text", 'removed'::"text"])))
);


ALTER TABLE "public"."group_members" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."groups" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "created_by" "uuid" NOT NULL,
    "archived_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "groups_name_check" CHECK ((("char_length"(TRIM(BOTH FROM "name")) >= 1) AND ("char_length"(TRIM(BOTH FROM "name")) <= 120)))
);


ALTER TABLE "public"."groups" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."itinerary_generations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "trip_id" "uuid" NOT NULL,
    "requested_by" "uuid" NOT NULL,
    "status" "text" DEFAULT 'draft'::"text" NOT NULL,
    "input_data" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "output_data" "jsonb",
    "model_name" "text",
    "error_message" "text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "itinerary_generations_status_check" CHECK (("status" = ANY (ARRAY['draft'::"text", 'generating'::"text", 'completed'::"text", 'failed'::"text", 'approved'::"text", 'rejected'::"text"])))
);


ALTER TABLE "public"."itinerary_generations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."itinerary_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "trip_id" "uuid" NOT NULL,
    "generation_id" "uuid",
    "created_by" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text",
    "category" "text",
    "location_name" "text",
    "address" "text",
    "latitude" double precision,
    "longitude" double precision,
    "starts_at" timestamp with time zone,
    "ends_at" timestamp with time zone,
    "estimated_cost" numeric(12,2),
    "sort_order" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "itinerary_items_check" CHECK ((("ends_at" IS NULL) OR ("starts_at" IS NULL) OR ("ends_at" >= "starts_at"))),
    CONSTRAINT "itinerary_items_estimated_cost_check" CHECK ((("estimated_cost" IS NULL) OR ("estimated_cost" >= (0)::numeric))),
    CONSTRAINT "itinerary_items_latitude_check" CHECK ((("latitude" IS NULL) OR (("latitude" >= ('-90'::integer)::double precision) AND ("latitude" <= (90)::double precision)))),
    CONSTRAINT "itinerary_items_longitude_check" CHECK ((("longitude" IS NULL) OR (("longitude" >= ('-180'::integer)::double precision) AND ("longitude" <= (180)::double precision))))
);


ALTER TABLE "public"."itinerary_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."location_shares" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "trip_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "accuracy_meters" numeric(10,2),
    "captured_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "expires_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "location_shares_accuracy_meters_check" CHECK ((("accuracy_meters" IS NULL) OR ("accuracy_meters" >= (0)::numeric))),
    CONSTRAINT "location_shares_latitude_check" CHECK ((("latitude" >= ('-90'::integer)::double precision) AND ("latitude" <= (90)::double precision))),
    CONSTRAINT "location_shares_longitude_check" CHECK ((("longitude" >= ('-180'::integer)::double precision) AND ("longitude" <= (180)::double precision)))
);


ALTER TABLE "public"."location_shares" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."meeting_points" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "trip_id" "uuid" NOT NULL,
    "created_by" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "address" "text",
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "scheduled_at" timestamp with time zone,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "meeting_points_latitude_check" CHECK ((("latitude" >= ('-90'::integer)::double precision) AND ("latitude" <= (90)::double precision))),
    CONSTRAINT "meeting_points_longitude_check" CHECK ((("longitude" >= ('-180'::integer)::double precision) AND ("longitude" <= (180)::double precision)))
);


ALTER TABLE "public"."meeting_points" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."member_preferences" (
    "user_id" "uuid" NOT NULL,
    "dietary_preferences" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "other_dietary_preference" "text",
    "allergies" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "other_allergy" "text",
    "preferred_activities" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "other_interests" "text",
    "budget_preference" numeric(12,2),
    "travel_pace" "text",
    "usual_free_days" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "visibility" "text" DEFAULT 'private'::"text" NOT NULL,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "member_preferences_budget_preference_check" CHECK ((("budget_preference" IS NULL) OR ("budget_preference" >= (0)::numeric))),
    CONSTRAINT "member_preferences_travel_pace_check" CHECK ((("travel_pace" IS NULL) OR ("travel_pace" = ANY (ARRAY['relaxed'::"text", 'balanced'::"text", 'packed'::"text"])))),
    CONSTRAINT "member_preferences_usual_free_days_check" CHECK (("usual_free_days" <@ ARRAY['Monday'::"text", 'Tuesday'::"text", 'Wednesday'::"text", 'Thursday'::"text", 'Friday'::"text", 'Saturday'::"text", 'Sunday'::"text"])),
    CONSTRAINT "member_preferences_visibility_check" CHECK (("visibility" = ANY (ARRAY['private'::"text", 'group_members'::"text"])))
);


ALTER TABLE "public"."member_preferences" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "group_id" "uuid",
    "trip_id" "uuid",
    "type" "text" NOT NULL,
    "title" "text" NOT NULL,
    "body" "text",
    "data" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "read_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."notifications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "avatar_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "first_name" "text",
    "last_name" "text",
    "username" "text"
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."settlements" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "trip_id" "uuid" NOT NULL,
    "payer_id" "uuid" NOT NULL,
    "payee_id" "uuid" NOT NULL,
    "amount" numeric(12,2) NOT NULL,
    "currency" character(3) DEFAULT 'PHP'::"bpchar" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "paid_at" timestamp with time zone,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "settlements_amount_check" CHECK (("amount" > (0)::numeric)),
    CONSTRAINT "settlements_check" CHECK (("payer_id" <> "payee_id")),
    CONSTRAINT "settlements_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'paid'::"text", 'cancelled'::"text"])))
);


ALTER TABLE "public"."settlements" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."subscription_plans" (
    "id" "text" NOT NULL,
    "name" "text" NOT NULL,
    "monthly_price" numeric(10,2),
    "trip_pass_price" numeric(10,2),
    "max_groups" integer,
    "max_members_per_group" integer,
    "max_active_trips" integer,
    "ai_generations_per_month" integer,
    "features" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "subscription_plans_ai_generations_per_month_check" CHECK ((("ai_generations_per_month" IS NULL) OR ("ai_generations_per_month" >= 0))),
    CONSTRAINT "subscription_plans_max_active_trips_check" CHECK ((("max_active_trips" IS NULL) OR ("max_active_trips" > 0))),
    CONSTRAINT "subscription_plans_max_groups_check" CHECK ((("max_groups" IS NULL) OR ("max_groups" > 0))),
    CONSTRAINT "subscription_plans_max_members_per_group_check" CHECK ((("max_members_per_group" IS NULL) OR ("max_members_per_group" > 0))),
    CONSTRAINT "subscription_plans_monthly_price_check" CHECK ((("monthly_price" IS NULL) OR ("monthly_price" >= (0)::numeric))),
    CONSTRAINT "subscription_plans_trip_pass_price_check" CHECK ((("trip_pass_price" IS NULL) OR ("trip_pass_price" >= (0)::numeric)))
);


ALTER TABLE "public"."subscription_plans" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."subscriptions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "plan_id" "text" NOT NULL,
    "status" "text" DEFAULT 'active'::"text" NOT NULL,
    "billing_interval" "text" DEFAULT 'month'::"text" NOT NULL,
    "provider" "text",
    "provider_customer_id" "text",
    "provider_subscription_id" "text",
    "current_period_start" timestamp with time zone,
    "current_period_end" timestamp with time zone,
    "cancel_at_period_end" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "subscriptions_billing_interval_check" CHECK (("billing_interval" = ANY (ARRAY['month'::"text", 'trip_pass'::"text"]))),
    CONSTRAINT "subscriptions_status_check" CHECK (("status" = ANY (ARRAY['trialing'::"text", 'active'::"text", 'past_due'::"text", 'paused'::"text", 'cancelled'::"text", 'expired'::"text"])))
);


ALTER TABLE "public"."subscriptions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."trip_members" (
    "trip_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "response" "text" DEFAULT 'pending'::"text" NOT NULL,
    "added_by" "uuid",
    "responded_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "trip_members_response_check" CHECK (("response" = ANY (ARRAY['pending'::"text", 'going'::"text", 'maybe'::"text", 'not_going'::"text"])))
);


ALTER TABLE "public"."trip_members" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."trips" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "group_id" "uuid" NOT NULL,
    "created_by" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "trip_type" "text" DEFAULT 'trip'::"text" NOT NULL,
    "status" "text" DEFAULT 'draft'::"text" NOT NULL,
    "starts_at" timestamp with time zone,
    "ends_at" timestamp with time zone,
    "destination_name" "text",
    "destination_latitude" double precision,
    "destination_longitude" double precision,
    "meeting_location_name" "text",
    "meeting_location_address" "text",
    "meeting_latitude" double precision,
    "meeting_longitude" double precision,
    "budget_per_person" numeric(12,2),
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "trips_budget_per_person_check" CHECK ((("budget_per_person" IS NULL) OR ("budget_per_person" >= (0)::numeric))),
    CONSTRAINT "trips_check" CHECK ((("ends_at" IS NULL) OR ("starts_at" IS NULL) OR ("ends_at" >= "starts_at"))),
    CONSTRAINT "trips_destination_latitude_check" CHECK ((("destination_latitude" IS NULL) OR (("destination_latitude" >= ('-90'::integer)::double precision) AND ("destination_latitude" <= (90)::double precision)))),
    CONSTRAINT "trips_destination_longitude_check" CHECK ((("destination_longitude" IS NULL) OR (("destination_longitude" >= ('-180'::integer)::double precision) AND ("destination_longitude" <= (180)::double precision)))),
    CONSTRAINT "trips_meeting_latitude_check" CHECK ((("meeting_latitude" IS NULL) OR (("meeting_latitude" >= ('-90'::integer)::double precision) AND ("meeting_latitude" <= (90)::double precision)))),
    CONSTRAINT "trips_meeting_longitude_check" CHECK ((("meeting_longitude" IS NULL) OR (("meeting_longitude" >= ('-180'::integer)::double precision) AND ("meeting_longitude" <= (180)::double precision)))),
    CONSTRAINT "trips_name_check" CHECK ((("char_length"(TRIM(BOTH FROM "name")) >= 1) AND ("char_length"(TRIM(BOTH FROM "name")) <= 160))),
    CONSTRAINT "trips_status_check" CHECK (("status" = ANY (ARRAY['draft'::"text", 'planned'::"text", 'active'::"text", 'completed'::"text", 'cancelled'::"text", 'archived'::"text"]))),
    CONSTRAINT "trips_trip_type_check" CHECK (("trip_type" = ANY (ARRAY['trip'::"text", 'hangout'::"text"])))
);


ALTER TABLE "public"."trips" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."usage_events" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "trip_id" "uuid",
    "event_type" "text" NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "usage_events_event_type_check" CHECK (("event_type" = ANY (ARRAY['ai_itinerary_generation'::"text", 'trip_created'::"text", 'group_created'::"text", 'expense_created'::"text"])))
);


ALTER TABLE "public"."usage_events" OWNER TO "postgres";


ALTER TABLE ONLY "public"."expense_shares"
    ADD CONSTRAINT "expense_shares_pkey" PRIMARY KEY ("expense_id", "user_id");



ALTER TABLE ONLY "public"."expenses"
    ADD CONSTRAINT "expenses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."group_invitations"
    ADD CONSTRAINT "group_invitations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."group_invitations"
    ADD CONSTRAINT "group_invitations_token_hash_key" UNIQUE ("token_hash");



ALTER TABLE ONLY "public"."group_members"
    ADD CONSTRAINT "group_members_pkey" PRIMARY KEY ("group_id", "user_id");



ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."itinerary_generations"
    ADD CONSTRAINT "itinerary_generations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."itinerary_items"
    ADD CONSTRAINT "itinerary_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."location_shares"
    ADD CONSTRAINT "location_shares_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."meeting_points"
    ADD CONSTRAINT "meeting_points_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."member_preferences"
    ADD CONSTRAINT "member_preferences_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_username_key" UNIQUE ("username");



ALTER TABLE ONLY "public"."settlements"
    ADD CONSTRAINT "settlements_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subscription_plans"
    ADD CONSTRAINT "subscription_plans_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_user_id_key" UNIQUE ("user_id");



ALTER TABLE ONLY "public"."trip_members"
    ADD CONSTRAINT "trip_members_pkey" PRIMARY KEY ("trip_id", "user_id");



ALTER TABLE ONLY "public"."trips"
    ADD CONSTRAINT "trips_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."usage_events"
    ADD CONSTRAINT "usage_events_pkey" PRIMARY KEY ("id");



CREATE INDEX "expense_shares_user_idx" ON "public"."expense_shares" USING "btree" ("user_id", "is_settled");



CREATE INDEX "expenses_trip_idx" ON "public"."expenses" USING "btree" ("trip_id", "occurred_at");



CREATE INDEX "group_members_user_idx" ON "public"."group_members" USING "btree" ("user_id", "status");



CREATE INDEX "groups_created_by_idx" ON "public"."groups" USING "btree" ("created_by");



CREATE INDEX "invitations_group_status_idx" ON "public"."group_invitations" USING "btree" ("group_id", "status");



CREATE INDEX "itinerary_items_trip_order_idx" ON "public"."itinerary_items" USING "btree" ("trip_id", "sort_order");



CREATE INDEX "locations_trip_captured_idx" ON "public"."location_shares" USING "btree" ("trip_id", "captured_at" DESC);



CREATE INDEX "notifications_user_read_idx" ON "public"."notifications" USING "btree" ("user_id", "read_at", "created_at" DESC);



CREATE UNIQUE INDEX "one_active_location_share_per_trip_user" ON "public"."location_shares" USING "btree" ("trip_id", "user_id") WHERE ("is_active" = true);



CREATE UNIQUE INDEX "one_active_organizer_per_group" ON "public"."group_members" USING "btree" ("group_id") WHERE (("role" = 'organizer'::"text") AND ("status" = 'active'::"text"));



CREATE UNIQUE INDEX "profiles_username_lower_key" ON "public"."profiles" USING "btree" ("lower"("username"));



CREATE UNIQUE INDEX "profiles_username_unique_idx" ON "public"."profiles" USING "btree" ("lower"("username"));



CREATE INDEX "settlements_trip_status_idx" ON "public"."settlements" USING "btree" ("trip_id", "status");



CREATE INDEX "trip_members_user_idx" ON "public"."trip_members" USING "btree" ("user_id", "response");



CREATE INDEX "trips_dates_idx" ON "public"."trips" USING "btree" ("starts_at", "ends_at");



CREATE INDEX "trips_group_status_idx" ON "public"."trips" USING "btree" ("group_id", "status");



CREATE INDEX "usage_events_user_type_date_idx" ON "public"."usage_events" USING "btree" ("user_id", "event_type", "created_at");



ALTER TABLE ONLY "public"."expense_shares"
    ADD CONSTRAINT "expense_shares_expense_id_fkey" FOREIGN KEY ("expense_id") REFERENCES "public"."expenses"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."expense_shares"
    ADD CONSTRAINT "expense_shares_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."expenses"
    ADD CONSTRAINT "expenses_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."expenses"
    ADD CONSTRAINT "expenses_paid_by_fkey" FOREIGN KEY ("paid_by") REFERENCES "auth"."users"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."expenses"
    ADD CONSTRAINT "expenses_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "public"."trips"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."group_invitations"
    ADD CONSTRAINT "group_invitations_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."group_invitations"
    ADD CONSTRAINT "group_invitations_invitee_user_id_fkey" FOREIGN KEY ("invitee_user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."group_invitations"
    ADD CONSTRAINT "group_invitations_inviter_id_fkey" FOREIGN KEY ("inviter_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."group_members"
    ADD CONSTRAINT "group_members_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."group_members"
    ADD CONSTRAINT "group_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."itinerary_generations"
    ADD CONSTRAINT "itinerary_generations_requested_by_fkey" FOREIGN KEY ("requested_by") REFERENCES "auth"."users"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."itinerary_generations"
    ADD CONSTRAINT "itinerary_generations_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "public"."trips"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."itinerary_items"
    ADD CONSTRAINT "itinerary_items_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."itinerary_items"
    ADD CONSTRAINT "itinerary_items_generation_id_fkey" FOREIGN KEY ("generation_id") REFERENCES "public"."itinerary_generations"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."itinerary_items"
    ADD CONSTRAINT "itinerary_items_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "public"."trips"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."location_shares"
    ADD CONSTRAINT "location_shares_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "public"."trips"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."location_shares"
    ADD CONSTRAINT "location_shares_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."meeting_points"
    ADD CONSTRAINT "meeting_points_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."meeting_points"
    ADD CONSTRAINT "meeting_points_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "public"."trips"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."member_preferences"
    ADD CONSTRAINT "member_preferences_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "public"."trips"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."settlements"
    ADD CONSTRAINT "settlements_payee_id_fkey" FOREIGN KEY ("payee_id") REFERENCES "auth"."users"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."settlements"
    ADD CONSTRAINT "settlements_payer_id_fkey" FOREIGN KEY ("payer_id") REFERENCES "auth"."users"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."settlements"
    ADD CONSTRAINT "settlements_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "public"."trips"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "public"."subscription_plans"("id");



ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."trip_members"
    ADD CONSTRAINT "trip_members_added_by_fkey" FOREIGN KEY ("added_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."trip_members"
    ADD CONSTRAINT "trip_members_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "public"."trips"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."trip_members"
    ADD CONSTRAINT "trip_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."trips"
    ADD CONSTRAINT "trips_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."trips"
    ADD CONSTRAINT "trips_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."usage_events"
    ADD CONSTRAINT "usage_events_trip_id_fkey" FOREIGN KEY ("trip_id") REFERENCES "public"."trips"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."usage_events"
    ADD CONSTRAINT "usage_events_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE "public"."expense_shares" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."expenses" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "expenses_delete_creator_or_admin" ON "public"."expenses" FOR DELETE TO "authenticated" USING ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "expenses"."trip_id") AND "public"."is_group_admin"("t"."group_id"))))));



CREATE POLICY "expenses_insert_trip_members" ON "public"."expenses" FOR INSERT TO "authenticated" WITH CHECK ((("created_by" = "auth"."uid"()) AND "public"."is_trip_member"("trip_id")));



CREATE POLICY "expenses_select_trip_members" ON "public"."expenses" FOR SELECT TO "authenticated" USING ("public"."is_trip_member"("trip_id"));



CREATE POLICY "expenses_update_creator_or_admin" ON "public"."expenses" FOR UPDATE TO "authenticated" USING ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "expenses"."trip_id") AND "public"."is_group_admin"("t"."group_id")))))) WITH CHECK ((("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "expenses"."trip_id") AND "public"."is_group_admin"("t"."group_id"))))));



ALTER TABLE "public"."group_invitations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."group_members" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "group_members_delete_admin" ON "public"."group_members" FOR DELETE TO "authenticated" USING ("public"."is_group_admin"("group_id"));



CREATE POLICY "group_members_insert_admin" ON "public"."group_members" FOR INSERT TO "authenticated" WITH CHECK ("public"."is_group_admin"("group_id"));



CREATE POLICY "group_members_select_members" ON "public"."group_members" FOR SELECT TO "authenticated" USING ("public"."is_group_member"("group_id"));



CREATE POLICY "group_members_update_admin" ON "public"."group_members" FOR UPDATE TO "authenticated" USING ("public"."is_group_admin"("group_id")) WITH CHECK ("public"."is_group_admin"("group_id"));



ALTER TABLE "public"."groups" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "groups_delete_admin" ON "public"."groups" FOR DELETE TO "authenticated" USING ("public"."is_group_admin"("id"));



CREATE POLICY "groups_insert_own" ON "public"."groups" FOR INSERT TO "authenticated" WITH CHECK (("created_by" = "auth"."uid"()));



CREATE POLICY "groups_select_members" ON "public"."groups" FOR SELECT TO "authenticated" USING ("public"."is_group_member"("id"));



CREATE POLICY "groups_update_admin" ON "public"."groups" FOR UPDATE TO "authenticated" USING ("public"."is_group_admin"("id")) WITH CHECK ("public"."is_group_admin"("id"));



CREATE POLICY "invitations_insert_admin" ON "public"."group_invitations" FOR INSERT TO "authenticated" WITH CHECK ((("inviter_id" = "auth"."uid"()) AND "public"."is_group_admin"("group_id")));



CREATE POLICY "invitations_select_relevant" ON "public"."group_invitations" FOR SELECT TO "authenticated" USING ((("inviter_id" = "auth"."uid"()) OR ("invitee_user_id" = "auth"."uid"()) OR "public"."is_group_admin"("group_id")));



CREATE POLICY "invitations_update_relevant" ON "public"."group_invitations" FOR UPDATE TO "authenticated" USING ((("inviter_id" = "auth"."uid"()) OR ("invitee_user_id" = "auth"."uid"()))) WITH CHECK ((("inviter_id" = "auth"."uid"()) OR ("invitee_user_id" = "auth"."uid"())));



ALTER TABLE "public"."itinerary_generations" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "itinerary_generations_insert_admin" ON "public"."itinerary_generations" FOR INSERT TO "authenticated" WITH CHECK ((("requested_by" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "itinerary_generations"."trip_id") AND "public"."is_group_admin"("t"."group_id"))))));



CREATE POLICY "itinerary_generations_select_trip_members" ON "public"."itinerary_generations" FOR SELECT TO "authenticated" USING ("public"."is_trip_member"("trip_id"));



CREATE POLICY "itinerary_generations_update_admin" ON "public"."itinerary_generations" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "itinerary_generations"."trip_id") AND "public"."is_group_admin"("t"."group_id"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "itinerary_generations"."trip_id") AND "public"."is_group_admin"("t"."group_id")))));



ALTER TABLE "public"."itinerary_items" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "itinerary_items_delete_admin" ON "public"."itinerary_items" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "itinerary_items"."trip_id") AND "public"."is_group_admin"("t"."group_id")))));



CREATE POLICY "itinerary_items_insert_admin" ON "public"."itinerary_items" FOR INSERT TO "authenticated" WITH CHECK ((("created_by" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "itinerary_items"."trip_id") AND "public"."is_group_admin"("t"."group_id"))))));



CREATE POLICY "itinerary_items_select_trip_members" ON "public"."itinerary_items" FOR SELECT TO "authenticated" USING ("public"."is_trip_member"("trip_id"));



CREATE POLICY "itinerary_items_update_admin" ON "public"."itinerary_items" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "itinerary_items"."trip_id") AND "public"."is_group_admin"("t"."group_id"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "itinerary_items"."trip_id") AND "public"."is_group_admin"("t"."group_id")))));



ALTER TABLE "public"."location_shares" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "locations_delete_own" ON "public"."location_shares" FOR DELETE TO "authenticated" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "locations_insert_own" ON "public"."location_shares" FOR INSERT TO "authenticated" WITH CHECK ((("user_id" = "auth"."uid"()) AND "public"."is_trip_member"("trip_id")));



CREATE POLICY "locations_select_trip_members" ON "public"."location_shares" FOR SELECT TO "authenticated" USING (("public"."is_trip_member"("trip_id") AND (("is_active" = true) OR ("user_id" = "auth"."uid"()))));



CREATE POLICY "locations_update_own" ON "public"."location_shares" FOR UPDATE TO "authenticated" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



ALTER TABLE "public"."meeting_points" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "meeting_points_delete_admin" ON "public"."meeting_points" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "meeting_points"."trip_id") AND "public"."is_group_admin"("t"."group_id")))));



CREATE POLICY "meeting_points_insert_admin" ON "public"."meeting_points" FOR INSERT TO "authenticated" WITH CHECK ((("created_by" = "auth"."uid"()) AND (EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "meeting_points"."trip_id") AND "public"."is_group_admin"("t"."group_id"))))));



CREATE POLICY "meeting_points_select_trip_members" ON "public"."meeting_points" FOR SELECT TO "authenticated" USING ("public"."is_trip_member"("trip_id"));



CREATE POLICY "meeting_points_update_admin" ON "public"."meeting_points" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "meeting_points"."trip_id") AND "public"."is_group_admin"("t"."group_id"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "meeting_points"."trip_id") AND "public"."is_group_admin"("t"."group_id")))));



ALTER TABLE "public"."member_preferences" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "notifications_select_own" ON "public"."notifications" FOR SELECT TO "authenticated" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "notifications_update_own" ON "public"."notifications" FOR UPDATE TO "authenticated" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "plans_select_authenticated" ON "public"."subscription_plans" FOR SELECT TO "authenticated" USING (("is_active" = true));



CREATE POLICY "preferences_delete_own" ON "public"."member_preferences" FOR DELETE TO "authenticated" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "preferences_insert_own" ON "public"."member_preferences" FOR INSERT TO "authenticated" WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "preferences_select_own_or_group" ON "public"."member_preferences" FOR SELECT TO "authenticated" USING ((("user_id" = "auth"."uid"()) OR (("visibility" = 'group_members'::"text") AND (EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."user_id" = "member_preferences"."user_id") AND "public"."is_group_member"("gm"."group_id")))))));



CREATE POLICY "preferences_update_own" ON "public"."member_preferences" FOR UPDATE TO "authenticated" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "profiles_insert_own" ON "public"."profiles" FOR INSERT TO "authenticated" WITH CHECK (("id" = "auth"."uid"()));



CREATE POLICY "profiles_select_authenticated" ON "public"."profiles" FOR SELECT TO "authenticated" USING ((("id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM ("public"."group_members" "mine"
     JOIN "public"."group_members" "theirs" ON (("theirs"."group_id" = "mine"."group_id")))
  WHERE (("mine"."user_id" = "auth"."uid"()) AND ("mine"."status" = 'active'::"text") AND ("theirs"."user_id" = "profiles"."id") AND ("theirs"."status" = 'active'::"text"))))));



CREATE POLICY "profiles_update_own" ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("id" = "auth"."uid"())) WITH CHECK (("id" = "auth"."uid"()));



ALTER TABLE "public"."settlements" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "settlements_insert_trip_members" ON "public"."settlements" FOR INSERT TO "authenticated" WITH CHECK ("public"."is_trip_member"("trip_id"));



CREATE POLICY "settlements_select_trip_members" ON "public"."settlements" FOR SELECT TO "authenticated" USING ("public"."is_trip_member"("trip_id"));



CREATE POLICY "settlements_update_payer_payee_or_admin" ON "public"."settlements" FOR UPDATE TO "authenticated" USING ((("payer_id" = "auth"."uid"()) OR ("payee_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "settlements"."trip_id") AND "public"."is_group_admin"("t"."group_id")))))) WITH CHECK ((("payer_id" = "auth"."uid"()) OR ("payee_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "settlements"."trip_id") AND "public"."is_group_admin"("t"."group_id"))))));



CREATE POLICY "shares_delete_expense_creator_or_admin" ON "public"."expense_shares" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."expenses" "e"
  WHERE (("e"."id" = "expense_shares"."expense_id") AND (("e"."created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."trips" "t"
          WHERE (("t"."id" = "e"."trip_id") AND "public"."is_group_admin"("t"."group_id")))))))));



CREATE POLICY "shares_insert_expense_creator_or_admin" ON "public"."expense_shares" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."expenses" "e"
  WHERE (("e"."id" = "expense_shares"."expense_id") AND (("e"."created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."trips" "t"
          WHERE (("t"."id" = "e"."trip_id") AND "public"."is_group_admin"("t"."group_id")))))))));



CREATE POLICY "shares_select_trip_members" ON "public"."expense_shares" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."expenses" "e"
  WHERE (("e"."id" = "expense_shares"."expense_id") AND "public"."is_trip_member"("e"."trip_id")))));



CREATE POLICY "shares_update_expense_creator_or_admin" ON "public"."expense_shares" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."expenses" "e"
  WHERE (("e"."id" = "expense_shares"."expense_id") AND (("e"."created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."trips" "t"
          WHERE (("t"."id" = "e"."trip_id") AND "public"."is_group_admin"("t"."group_id"))))))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."expenses" "e"
  WHERE (("e"."id" = "expense_shares"."expense_id") AND (("e"."created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
           FROM "public"."trips" "t"
          WHERE (("t"."id" = "e"."trip_id") AND "public"."is_group_admin"("t"."group_id")))))))));



ALTER TABLE "public"."subscription_plans" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."subscriptions" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "subscriptions_select_own" ON "public"."subscriptions" FOR SELECT TO "authenticated" USING (("user_id" = "auth"."uid"()));



ALTER TABLE "public"."trip_members" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "trip_members_delete_admin" ON "public"."trip_members" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "trip_members"."trip_id") AND "public"."is_group_admin"("t"."group_id")))));



CREATE POLICY "trip_members_insert_admin" ON "public"."trip_members" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "trip_members"."trip_id") AND "public"."is_group_admin"("t"."group_id")))));



CREATE POLICY "trip_members_select_members" ON "public"."trip_members" FOR SELECT TO "authenticated" USING (("public"."is_trip_member"("trip_id") OR ("user_id" = "auth"."uid"())));



CREATE POLICY "trip_members_update_self_or_admin" ON "public"."trip_members" FOR UPDATE TO "authenticated" USING ((("user_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "trip_members"."trip_id") AND "public"."is_group_admin"("t"."group_id")))))) WITH CHECK ((("user_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."trips" "t"
  WHERE (("t"."id" = "trip_members"."trip_id") AND "public"."is_group_admin"("t"."group_id"))))));



ALTER TABLE "public"."trips" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "trips_delete_admin" ON "public"."trips" FOR DELETE TO "authenticated" USING ("public"."is_group_admin"("group_id"));



CREATE POLICY "trips_insert_admin" ON "public"."trips" FOR INSERT TO "authenticated" WITH CHECK ((("created_by" = "auth"."uid"()) AND "public"."is_group_admin"("group_id")));



CREATE POLICY "trips_select_members" ON "public"."trips" FOR SELECT TO "authenticated" USING ("public"."is_group_member"("group_id"));



CREATE POLICY "trips_update_admin" ON "public"."trips" FOR UPDATE TO "authenticated" USING ("public"."is_group_admin"("group_id")) WITH CHECK ("public"."is_group_admin"("group_id"));



ALTER TABLE "public"."usage_events" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "usage_events_insert_own" ON "public"."usage_events" FOR INSERT TO "authenticated" WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "usage_events_select_own" ON "public"."usage_events" FOR SELECT TO "authenticated" USING (("user_id" = "auth"."uid"()));





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";






















































































































































REVOKE ALL ON FUNCTION "public"."email_exists"("p_email" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."email_exists"("p_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."email_exists"("p_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."email_exists"("p_email" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."email_status"("p_email" "text") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."email_status"("p_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."email_status"("p_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."email_status"("p_email" "text") TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_group_usual_free_days"("target_group_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_group_usual_free_days"("target_group_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_group_usual_free_days"("target_group_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_group_usual_free_days"("target_group_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_group_admin"("target_group_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_group_admin"("target_group_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_group_admin"("target_group_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_group_member"("target_group_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_group_member"("target_group_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_group_member"("target_group_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_trip_member"("target_trip_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_trip_member"("target_trip_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_trip_member"("target_trip_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."username_available"("p_username" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."username_available"("p_username" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."username_available"("p_username" "text") TO "service_role";


















GRANT ALL ON TABLE "public"."expense_shares" TO "anon";
GRANT ALL ON TABLE "public"."expense_shares" TO "authenticated";
GRANT ALL ON TABLE "public"."expense_shares" TO "service_role";



GRANT ALL ON TABLE "public"."expenses" TO "anon";
GRANT ALL ON TABLE "public"."expenses" TO "authenticated";
GRANT ALL ON TABLE "public"."expenses" TO "service_role";



GRANT ALL ON TABLE "public"."group_invitations" TO "anon";
GRANT ALL ON TABLE "public"."group_invitations" TO "authenticated";
GRANT ALL ON TABLE "public"."group_invitations" TO "service_role";



GRANT ALL ON TABLE "public"."group_members" TO "anon";
GRANT ALL ON TABLE "public"."group_members" TO "authenticated";
GRANT ALL ON TABLE "public"."group_members" TO "service_role";



GRANT ALL ON TABLE "public"."groups" TO "anon";
GRANT ALL ON TABLE "public"."groups" TO "authenticated";
GRANT ALL ON TABLE "public"."groups" TO "service_role";



GRANT ALL ON TABLE "public"."itinerary_generations" TO "anon";
GRANT ALL ON TABLE "public"."itinerary_generations" TO "authenticated";
GRANT ALL ON TABLE "public"."itinerary_generations" TO "service_role";



GRANT ALL ON TABLE "public"."itinerary_items" TO "anon";
GRANT ALL ON TABLE "public"."itinerary_items" TO "authenticated";
GRANT ALL ON TABLE "public"."itinerary_items" TO "service_role";



GRANT ALL ON TABLE "public"."location_shares" TO "anon";
GRANT ALL ON TABLE "public"."location_shares" TO "authenticated";
GRANT ALL ON TABLE "public"."location_shares" TO "service_role";



GRANT ALL ON TABLE "public"."meeting_points" TO "anon";
GRANT ALL ON TABLE "public"."meeting_points" TO "authenticated";
GRANT ALL ON TABLE "public"."meeting_points" TO "service_role";



GRANT ALL ON TABLE "public"."member_preferences" TO "anon";
GRANT ALL ON TABLE "public"."member_preferences" TO "authenticated";
GRANT ALL ON TABLE "public"."member_preferences" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."settlements" TO "anon";
GRANT ALL ON TABLE "public"."settlements" TO "authenticated";
GRANT ALL ON TABLE "public"."settlements" TO "service_role";



GRANT ALL ON TABLE "public"."subscription_plans" TO "anon";
GRANT ALL ON TABLE "public"."subscription_plans" TO "authenticated";
GRANT ALL ON TABLE "public"."subscription_plans" TO "service_role";



GRANT ALL ON TABLE "public"."subscriptions" TO "anon";
GRANT ALL ON TABLE "public"."subscriptions" TO "authenticated";
GRANT ALL ON TABLE "public"."subscriptions" TO "service_role";



GRANT ALL ON TABLE "public"."trip_members" TO "anon";
GRANT ALL ON TABLE "public"."trip_members" TO "authenticated";
GRANT ALL ON TABLE "public"."trip_members" TO "service_role";



GRANT ALL ON TABLE "public"."trips" TO "anon";
GRANT ALL ON TABLE "public"."trips" TO "authenticated";
GRANT ALL ON TABLE "public"."trips" TO "service_role";



GRANT ALL ON TABLE "public"."usage_events" TO "anon";
GRANT ALL ON TABLE "public"."usage_events" TO "authenticated";
GRANT ALL ON TABLE "public"."usage_events" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































