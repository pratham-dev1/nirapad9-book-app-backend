PGDMP  4                    }            Slot_Booking    16.3    16.3 �   j           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            k           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            l           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            m           1262    16399    Slot_Booking    DATABASE     �   CREATE DATABASE "Slot_Booking" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_India.1252';
    DROP DATABASE "Slot_Booking";
                postgres    false            �           1255    24481    add_org_tab_names()    FUNCTION       CREATE FUNCTION public.add_org_tab_names() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    INSERT INTO org_tab_names ("tabNameOrgGiven", "tabId", "orgId")

    SELECT tn."tabName", tn.id, NEW.id

    FROM tab_names tn;
 
    RETURN NEW;

END;

$$;
 *   DROP FUNCTION public.add_org_tab_names();
       public          postgres    false            �           1255    39917 !   log_open_availability_questions()    FUNCTION     $  CREATE FUNCTION public.log_open_availability_questions() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO open_availability_questions_change_log ("openAvailabilityTagId", "questionId")
    VALUES (NEW."openAvailabilityTagId", NEW."questionId");
 
    RETURN NEW;
END;
$$;
 8   DROP FUNCTION public.log_open_availability_questions();
       public          postgres    false            �           1255    26371    set_active_flag()    FUNCTION     �  CREATE FUNCTION public.set_active_flag() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Set all rows with the same eventId, userId, and emailAccount to activeFlag = false
    UPDATE events
    SET "activeFlag" = false
    WHERE "eventId" = NEW."eventId"
      AND "userId" = NEW."userId"
      AND "emailAccount" = NEW."emailAccount";
 
    -- Set activeFlag = true for the row with the latest updatedAt timestamp
    UPDATE events
    SET "activeFlag" = true
    WHERE id = (
        SELECT id
        FROM events
        WHERE "eventId" = NEW."eventId"
          AND "userId" = NEW."userId"
          AND "emailAccount" = NEW."emailAccount"
        ORDER BY "updatedAt" DESC
        LIMIT 1
    );
 
    RETURN NEW;
END;
$$;
 (   DROP FUNCTION public.set_active_flag();
       public          postgres    false            �           1259    51445 
   app_access    TABLE     w   CREATE TABLE public.app_access (
    "userId" integer NOT NULL,
    "applicationId" character varying(255) NOT NULL
);
    DROP TABLE public.app_access;
       public         heap    postgres    false            �           1259    51419    applications    TABLE     n   CREATE TABLE public.applications (
    id character varying(255) NOT NULL,
    name character varying(255)
);
     DROP TABLE public.applications;
       public         heap    postgres    false                       1259    38994    availabilities    TABLE     U  CREATE TABLE public.availabilities (
    id integer NOT NULL,
    "tpId" integer NOT NULL,
    datetime character varying(255) NOT NULL,
    "candidateId" character varying(255),
    "interviewStatus" character varying(255),
    booked boolean DEFAULT false NOT NULL,
    "bookedBy" integer,
    "formLink" text,
    "meetingLink" text,
    "isCancelled" boolean DEFAULT false,
    "cancelReasonByRecruiter" text,
    "recordTime" integer,
    "recordTimeComments" character varying(255),
    "isRecordTimeSubmitted" boolean,
    "tpCancellationReason" text,
    endtime character varying(255)
);
 "   DROP TABLE public.availabilities;
       public         heap    postgres    false                       1259    38993    availabilities_id_seq    SEQUENCE     �   CREATE SEQUENCE public.availabilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.availabilities_id_seq;
       public          postgres    false    260            n           0    0    availabilities_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.availabilities_id_seq OWNED BY public.availabilities.id;
          public          postgres    false    259            y           1259    39714    availability_secondary_skills    TABLE     �   CREATE TABLE public.availability_secondary_skills (
    "availabilityId" integer NOT NULL,
    "secondarySkillId" integer NOT NULL
);
 1   DROP TABLE public.availability_secondary_skills;
       public         heap    postgres    false            |           1259    39759 &   availability_secondary_skills_searched    TABLE     �   CREATE TABLE public.availability_secondary_skills_searched (
    "availabilityId" integer NOT NULL,
    "secondarySkillId" integer NOT NULL
);
 :   DROP TABLE public.availability_secondary_skills_searched;
       public         heap    postgres    false            x           1259    39699    availability_skills    TABLE     s   CREATE TABLE public.availability_skills (
    "availabilityId" integer NOT NULL,
    "skillId" integer NOT NULL
);
 '   DROP TABLE public.availability_skills;
       public         heap    postgres    false            {           1259    39744    availability_skills_searched    TABLE     |   CREATE TABLE public.availability_skills_searched (
    "availabilityId" integer NOT NULL,
    "skillId" integer NOT NULL
);
 0   DROP TABLE public.availability_skills_searched;
       public         heap    postgres    false            >           1259    39358    ba_organizations    TABLE     �   CREATE TABLE public.ba_organizations (
    id integer NOT NULL,
    "organizationName" character varying(255) NOT NULL,
    "organizationLogo" character varying(255),
    "isOrgDisabledTagLogo" boolean DEFAULT false
);
 $   DROP TABLE public.ba_organizations;
       public         heap    postgres    false            =           1259    39357    ba_organizations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.ba_organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.ba_organizations_id_seq;
       public          postgres    false    318            o           0    0    ba_organizations_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.ba_organizations_id_seq OWNED BY public.ba_organizations.id;
          public          postgres    false    317            �           1259    51351 "   blocked_email_by_slot_broadcasters    TABLE     �   CREATE TABLE public.blocked_email_by_slot_broadcasters (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    "tagOwnerUserId" integer NOT NULL,
    "tagId" integer NOT NULL
);
 6   DROP TABLE public.blocked_email_by_slot_broadcasters;
       public         heap    postgres    false            �           1259    51350 )   blocked_email_by_slot_broadcasters_id_seq    SEQUENCE     �   CREATE SEQUENCE public.blocked_email_by_slot_broadcasters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 @   DROP SEQUENCE public.blocked_email_by_slot_broadcasters_id_seq;
       public          postgres    false    430            p           0    0 )   blocked_email_by_slot_broadcasters_id_seq    SEQUENCE OWNED BY     w   ALTER SEQUENCE public.blocked_email_by_slot_broadcasters_id_seq OWNED BY public.blocked_email_by_slot_broadcasters.id;
          public          postgres    false    429            0           1259    39258    cities    TABLE     p   CREATE TABLE public.cities (
    id integer NOT NULL,
    name character varying(255),
    "stateId" integer
);
    DROP TABLE public.cities;
       public         heap    postgres    false            /           1259    39257    cities_id_seq    SEQUENCE     �   CREATE SEQUENCE public.cities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.cities_id_seq;
       public          postgres    false    304            q           0    0    cities_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.cities_id_seq OWNED BY public.cities.id;
          public          postgres    false    303            X           1259    39493    contacts    TABLE     7  CREATE TABLE public.contacts (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    firstname character varying(255),
    lastname character varying(255),
    email character varying(255) NOT NULL,
    phone character varying(255),
    title character varying(255),
    company character varying(255)
);
    DROP TABLE public.contacts;
       public         heap    postgres    false            W           1259    39492    contacts_id_seq    SEQUENCE     �   CREATE SEQUENCE public.contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.contacts_id_seq;
       public          postgres    false    344            r           0    0    contacts_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;
          public          postgres    false    343            �           1259    76318 	   countries    TABLE     \   CREATE TABLE public.countries (
    id integer NOT NULL,
    name character varying(255)
);
    DROP TABLE public.countries;
       public         heap    postgres    false            �           1259    76317    countries_id_seq    SEQUENCE     �   CREATE SEQUENCE public.countries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.countries_id_seq;
       public          postgres    false    438            s           0    0    countries_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.countries_id_seq OWNED BY public.countries.id;
          public          postgres    false    437            "           1259    39157    course    TABLE     a   CREATE TABLE public.course (
    id integer NOT NULL,
    "courseName" character varying(255)
);
    DROP TABLE public.course;
       public         heap    postgres    false            !           1259    39156    course_id_seq    SEQUENCE     �   CREATE SEQUENCE public.course_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.course_id_seq;
       public          postgres    false    290            t           0    0    course_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.course_id_seq OWNED BY public.course.id;
          public          postgres    false    289            �           1259    42561    credential_blocked_logs    TABLE     �   CREATE TABLE public.credential_blocked_logs (
    id integer NOT NULL,
    "userId" integer,
    "createdAt" character varying(255)
);
 +   DROP TABLE public.credential_blocked_logs;
       public         heap    postgres    false            �           1259    42560    credential_blocked_logs_id_seq    SEQUENCE     �   CREATE SEQUENCE public.credential_blocked_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.credential_blocked_logs_id_seq;
       public          postgres    false    422            u           0    0    credential_blocked_logs_id_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.credential_blocked_logs_id_seq OWNED BY public.credential_blocked_logs.id;
          public          postgres    false    421            b           1259    39543 !   crm_internal_communication_status    TABLE        CREATE TABLE public.crm_internal_communication_status (
    id integer NOT NULL,
    status character varying(255) NOT NULL
);
 5   DROP TABLE public.crm_internal_communication_status;
       public         heap    postgres    false            a           1259    39542 (   crm_internal_communication_status_id_seq    SEQUENCE     �   CREATE SEQUENCE public.crm_internal_communication_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ?   DROP SEQUENCE public.crm_internal_communication_status_id_seq;
       public          postgres    false    354            v           0    0 (   crm_internal_communication_status_id_seq    SEQUENCE OWNED BY     u   ALTER SEQUENCE public.crm_internal_communication_status_id_seq OWNED BY public.crm_internal_communication_status.id;
          public          postgres    false    353            n           1259    39627 '   crm_internal_email_communication_status    TABLE     �   CREATE TABLE public.crm_internal_email_communication_status (
    id integer NOT NULL,
    status character varying(255) NOT NULL
);
 ;   DROP TABLE public.crm_internal_email_communication_status;
       public         heap    postgres    false            m           1259    39626 .   crm_internal_email_communication_status_id_seq    SEQUENCE     �   CREATE SEQUENCE public.crm_internal_email_communication_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 E   DROP SEQUENCE public.crm_internal_email_communication_status_id_seq;
       public          postgres    false    366            w           0    0 .   crm_internal_email_communication_status_id_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public.crm_internal_email_communication_status_id_seq OWNED BY public.crm_internal_email_communication_status.id;
          public          postgres    false    365            h           1259    39589    crm_internal_lead_company_infos    TABLE     �  CREATE TABLE public.crm_internal_lead_company_infos (
    id integer NOT NULL,
    "leadId" integer,
    "companyName" character varying(255),
    website character varying(255),
    "linkedIn" character varying(255),
    "companySize" integer,
    "totalEmployees" integer,
    "annualRevenue" character varying(255),
    industry character varying(255),
    description character varying(255)
);
 3   DROP TABLE public.crm_internal_lead_company_infos;
       public         heap    postgres    false            g           1259    39588 &   crm_internal_lead_company_infos_id_seq    SEQUENCE     �   CREATE SEQUENCE public.crm_internal_lead_company_infos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 =   DROP SEQUENCE public.crm_internal_lead_company_infos_id_seq;
       public          postgres    false    360            x           0    0 &   crm_internal_lead_company_infos_id_seq    SEQUENCE OWNED BY     q   ALTER SEQUENCE public.crm_internal_lead_company_infos_id_seq OWNED BY public.crm_internal_lead_company_infos.id;
          public          postgres    false    359            f           1259    39567    crm_internal_lead_contact_infos    TABLE     �  CREATE TABLE public.crm_internal_lead_contact_infos (
    id integer NOT NULL,
    "leadId" integer,
    email1 character varying(255),
    "accuracyForEmail1" boolean DEFAULT false,
    "communicationStatusForEmail1" integer,
    "notesForEmail1" character varying(255),
    email2 character varying(255),
    "accuracyForEmail2" boolean DEFAULT false,
    "communicationStatusForEmail2" integer,
    "notesForEmail2" character varying(255),
    phone1 character varying(255),
    "accuracyForPhone1" boolean DEFAULT false,
    "communicationStatusForPhone1" integer,
    "notesForPhone1" character varying(255),
    phone2 character varying(255),
    "accuracyForPhone2" boolean DEFAULT false,
    "communicationStatusForPhone2" integer,
    "notesForPhone2" character varying(255),
    phone3 character varying(255),
    "accuracyForPhone3" boolean DEFAULT false,
    "communicationStatusForPhone3" integer,
    "notesForPhone3" character varying(255),
    phone4 character varying(255),
    "accuracyForPhone4" boolean DEFAULT false,
    "communicationStatusForPhone4" integer,
    "notesForPhone4" character varying(255),
    phone5 character varying(255),
    "accuracyForPhone5" boolean DEFAULT false,
    "communicationStatusForPhone5" integer,
    "notesForPhone5" character varying(255),
    "linkedIn" character varying(255),
    "accuracyForLinkedIn" boolean DEFAULT false,
    "communicationStatusForLinkedIn" integer,
    "notesForLinkedIn" character varying(255)
);
 3   DROP TABLE public.crm_internal_lead_contact_infos;
       public         heap    postgres    false            e           1259    39566 &   crm_internal_lead_contact_infos_id_seq    SEQUENCE     �   CREATE SEQUENCE public.crm_internal_lead_contact_infos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 =   DROP SEQUENCE public.crm_internal_lead_contact_infos_id_seq;
       public          postgres    false    358            y           0    0 &   crm_internal_lead_contact_infos_id_seq    SEQUENCE OWNED BY     q   ALTER SEQUENCE public.crm_internal_lead_contact_infos_id_seq OWNED BY public.crm_internal_lead_contact_infos.id;
          public          postgres    false    357            d           1259    39550    crm_internal_lead_infos    TABLE     V  CREATE TABLE public.crm_internal_lead_infos (
    id integer NOT NULL,
    firstname character varying(255),
    lastname character varying(255),
    title character varying(255),
    company character varying(255),
    email character varying(255),
    "accuracyForEmail" boolean DEFAULT false,
    "communicationStatusForEmail" integer,
    "notesForEmail" character varying(255),
    phone character varying(255),
    "accuracyForPhone" boolean DEFAULT false,
    "communicationStatusForPhone" integer,
    "notesForPhone" character varying(255),
    locality character varying(255),
    state character varying(255),
    country character varying(255),
    "communicationStatus" integer,
    "viableLead" character varying(255),
    "createdBy" integer,
    "createdOn" character varying(255) DEFAULT '2024-09-30T09:13:55.952Z'::character varying
);
 +   DROP TABLE public.crm_internal_lead_infos;
       public         heap    postgres    false            c           1259    39549    crm_internal_lead_infos_id_seq    SEQUENCE     �   CREATE SEQUENCE public.crm_internal_lead_infos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.crm_internal_lead_infos_id_seq;
       public          postgres    false    356            z           0    0    crm_internal_lead_infos_id_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.crm_internal_lead_infos_id_seq OWNED BY public.crm_internal_lead_infos.id;
          public          postgres    false    355            j           1259    39603    crm_internal_lead_notes    TABLE     �   CREATE TABLE public.crm_internal_lead_notes (
    id integer NOT NULL,
    "leadId" integer NOT NULL,
    notes character varying(255)
);
 +   DROP TABLE public.crm_internal_lead_notes;
       public         heap    postgres    false            i           1259    39602    crm_internal_lead_notes_id_seq    SEQUENCE     �   CREATE SEQUENCE public.crm_internal_lead_notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.crm_internal_lead_notes_id_seq;
       public          postgres    false    362            {           0    0    crm_internal_lead_notes_id_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.crm_internal_lead_notes_id_seq OWNED BY public.crm_internal_lead_notes.id;
          public          postgres    false    361            l           1259    39615    crm_internal_lead_tags    TABLE     �   CREATE TABLE public.crm_internal_lead_tags (
    id integer NOT NULL,
    "leadId" integer NOT NULL,
    "tagName" character varying(255) NOT NULL
);
 *   DROP TABLE public.crm_internal_lead_tags;
       public         heap    postgres    false            k           1259    39614    crm_internal_lead_tags_id_seq    SEQUENCE     �   CREATE SEQUENCE public.crm_internal_lead_tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.crm_internal_lead_tags_id_seq;
       public          postgres    false    364            |           0    0    crm_internal_lead_tags_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.crm_internal_lead_tags_id_seq OWNED BY public.crm_internal_lead_tags.id;
          public          postgres    false    363            r           1259    39641 *   crm_internal_linkedIn_communication_status    TABLE     �   CREATE TABLE public."crm_internal_linkedIn_communication_status" (
    id integer NOT NULL,
    status character varying(255) NOT NULL
);
 @   DROP TABLE public."crm_internal_linkedIn_communication_status";
       public         heap    postgres    false            q           1259    39640 1   crm_internal_linkedIn_communication_status_id_seq    SEQUENCE     �   CREATE SEQUENCE public."crm_internal_linkedIn_communication_status_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 J   DROP SEQUENCE public."crm_internal_linkedIn_communication_status_id_seq";
       public          postgres    false    370            }           0    0 1   crm_internal_linkedIn_communication_status_id_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public."crm_internal_linkedIn_communication_status_id_seq" OWNED BY public."crm_internal_linkedIn_communication_status".id;
          public          postgres    false    369            p           1259    39634 '   crm_internal_phone_communication_status    TABLE     �   CREATE TABLE public.crm_internal_phone_communication_status (
    id integer NOT NULL,
    status character varying(255) NOT NULL
);
 ;   DROP TABLE public.crm_internal_phone_communication_status;
       public         heap    postgres    false            o           1259    39633 .   crm_internal_phone_communication_status_id_seq    SEQUENCE     �   CREATE SEQUENCE public.crm_internal_phone_communication_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 E   DROP SEQUENCE public.crm_internal_phone_communication_status_id_seq;
       public          postgres    false    368            ~           0    0 .   crm_internal_phone_communication_status_id_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public.crm_internal_phone_communication_status_id_seq OWNED BY public.crm_internal_phone_communication_status.id;
          public          postgres    false    367            t           1259    39648    crm_internal_user_types    TABLE     y   CREATE TABLE public.crm_internal_user_types (
    id integer NOT NULL,
    "userType" character varying(255) NOT NULL
);
 +   DROP TABLE public.crm_internal_user_types;
       public         heap    postgres    false            s           1259    39647    crm_internal_user_types_id_seq    SEQUENCE     �   CREATE SEQUENCE public.crm_internal_user_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.crm_internal_user_types_id_seq;
       public          postgres    false    372                       0    0    crm_internal_user_types_id_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.crm_internal_user_types_id_seq OWNED BY public.crm_internal_user_types.id;
          public          postgres    false    371            `           1259    39534    crm_internal_users    TABLE     �   CREATE TABLE public.crm_internal_users (
    id integer NOT NULL,
    username character varying(255) NOT NULL,
    fullname character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    "userTypeId" integer NOT NULL
);
 &   DROP TABLE public.crm_internal_users;
       public         heap    postgres    false            _           1259    39533    crm_internal_users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.crm_internal_users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.crm_internal_users_id_seq;
       public          postgres    false    352            �           0    0    crm_internal_users_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.crm_internal_users_id_seq OWNED BY public.crm_internal_users.id;
          public          postgres    false    351            �           1259    42297    dashboard_search_options    TABLE     �   CREATE TABLE public.dashboard_search_options (
    id integer NOT NULL,
    category character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    path character varying(255) NOT NULL
);
 ,   DROP TABLE public.dashboard_search_options;
       public         heap    postgres    false            �           1259    42296    dashboard_search_options_id_seq    SEQUENCE     �   CREATE SEQUENCE public.dashboard_search_options_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.dashboard_search_options_id_seq;
       public          postgres    false    406            �           0    0    dashboard_search_options_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.dashboard_search_options_id_seq OWNED BY public.dashboard_search_options.id;
          public          postgres    false    405            �            1259    38905    designations    TABLE     f   CREATE TABLE public.designations (
    id integer NOT NULL,
    designation character varying(255)
);
     DROP TABLE public.designations;
       public         heap    postgres    false            �            1259    38904    designations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.designations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.designations_id_seq;
       public          postgres    false    252            �           0    0    designations_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.designations_id_seq OWNED BY public.designations.id;
          public          postgres    false    251            ,           1259    39194    education_details    TABLE     �  CREATE TABLE public.education_details (
    id integer NOT NULL,
    "startDate" character varying(255) NOT NULL,
    "endDate" character varying(255),
    "isCurrentlyPursuing" boolean DEFAULT false,
    "userId" integer NOT NULL,
    "institutionId" integer,
    "courseId" integer,
    "userSuggestedInstitutionId" integer,
    "userSuggestedCourseId" integer,
    "educationLevelId" integer,
    "fieldOfStudyId" integer
);
 %   DROP TABLE public.education_details;
       public         heap    postgres    false            +           1259    39193    education_details_id_seq    SEQUENCE     �   CREATE SEQUENCE public.education_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.education_details_id_seq;
       public          postgres    false    300            �           0    0    education_details_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.education_details_id_seq OWNED BY public.education_details.id;
          public          postgres    false    299            (           1259    39180    education_level    TABLE     b   CREATE TABLE public.education_level (
    id integer NOT NULL,
    name character varying(255)
);
 #   DROP TABLE public.education_level;
       public         heap    postgres    false            '           1259    39179    education_level_id_seq    SEQUENCE     �   CREATE SEQUENCE public.education_level_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.education_level_id_seq;
       public          postgres    false    296            �           0    0    education_level_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.education_level_id_seq OWNED BY public.education_level.id;
          public          postgres    false    295            �           1259    42484    email_support_categories    TABLE     k   CREATE TABLE public.email_support_categories (
    id integer NOT NULL,
    name character varying(255)
);
 ,   DROP TABLE public.email_support_categories;
       public         heap    postgres    false            �           1259    42483    email_support_categories_id_seq    SEQUENCE     �   CREATE SEQUENCE public.email_support_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.email_support_categories_id_seq;
       public          postgres    false    414            �           0    0    email_support_categories_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.email_support_categories_id_seq OWNED BY public.email_support_categories.id;
          public          postgres    false    413            �           1259    42491    email_supports    TABLE        CREATE TABLE public.email_supports (
    id integer NOT NULL,
    "userId" integer,
    "categoryId" integer,
    text text
);
 "   DROP TABLE public.email_supports;
       public         heap    postgres    false            �           1259    42490    email_supports_id_seq    SEQUENCE     �   CREATE SEQUENCE public.email_supports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.email_supports_id_seq;
       public          postgres    false    416            �           0    0    email_supports_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.email_supports_id_seq OWNED BY public.email_supports.id;
          public          postgres    false    415            �            1259    38896    event_colors    TABLE     �   CREATE TABLE public.event_colors (
    id integer NOT NULL,
    color character varying(255),
    theme character varying(255),
    email_column character varying(255)
);
     DROP TABLE public.event_colors;
       public         heap    postgres    false            �            1259    38895    event_colors_id_seq    SEQUENCE     �   CREATE SEQUENCE public.event_colors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.event_colors_id_seq;
       public          postgres    false    250            �           0    0    event_colors_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.event_colors_id_seq OWNED BY public.event_colors.id;
          public          postgres    false    249            @           1259    39367    event_drafts    TABLE     �  CREATE TABLE public.event_drafts (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    title character varying(255) NOT NULL,
    "draftName" character varying(255) NOT NULL,
    "requiredGuests" character varying(255) NOT NULL,
    "optionalGuests" character varying(255) NOT NULL,
    date character varying(255) NOT NULL,
    "startTime" character varying(255) NOT NULL,
    "eventTime" integer NOT NULL,
    "senderEmail" character varying(255) NOT NULL,
    template text NOT NULL,
    "eventTypeId" integer,
    recurrence character varying(255),
    "recurrenceRepeat" character varying(255),
    "recurrenceEndDate" character varying(255),
    "recurrenceCount" character varying(255),
    "recurrenceNeverEnds" boolean,
    "recurrenceDays" text,
    "predefinedMeetId" integer,
    "isEmailDeleted" boolean DEFAULT false,
    "descriptionCheck" boolean DEFAULT true,
    "emailCheck" boolean DEFAULT true,
    "hideGuestList" boolean DEFAULT false
);
     DROP TABLE public.event_drafts;
       public         heap    postgres    false            ?           1259    39366    event_drafts_id_seq    SEQUENCE     �   CREATE SEQUENCE public.event_drafts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.event_drafts_id_seq;
       public          postgres    false    320            �           0    0    event_drafts_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.event_drafts_id_seq OWNED BY public.event_drafts.id;
          public          postgres    false    319            P           1259    39460    event_hub_events    TABLE     �  CREATE TABLE public.event_hub_events (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "startTime" character varying(255),
    "endTime" character varying(255),
    title character varying(255),
    "senderEmail" character varying(255),
    attendees text,
    "meetingLink" text,
    "eventId" text,
    "eventDurationInMinutes" integer,
    "eventTypeId" integer,
    "emailTemplate" text,
    "isCancelled" boolean DEFAULT false,
    "meetType" integer
);
 $   DROP TABLE public.event_hub_events;
       public         heap    postgres    false            O           1259    39459    event_hub_events_id_seq    SEQUENCE     �   CREATE SEQUENCE public.event_hub_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.event_hub_events_id_seq;
       public          postgres    false    336            �           0    0    event_hub_events_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.event_hub_events_id_seq OWNED BY public.event_hub_events.id;
          public          postgres    false    335            N           1259    39453    event_types    TABLE     _   CREATE TABLE public.event_types (
    id integer NOT NULL,
    value character varying(255)
);
    DROP TABLE public.event_types;
       public         heap    postgres    false            
           1259    39024    events    TABLE     F  CREATE TABLE public.events (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "eventId" character varying(255) NOT NULL,
    "startTime" character varying(255),
    "endTime" character varying(255),
    sender character varying(255),
    title character varying(255),
    attendees text,
    "meetingLink" text,
    "emailAccount" character varying(255),
    "seriesMasterId" text,
    "updatedAt" character varying(255) NOT NULL,
    "isCancelled" boolean DEFAULT false,
    "isDeleted" boolean DEFAULT false,
    "activeFlag" boolean,
    "eventColorId" integer,
    "eventColor" character varying(255),
    "isReminderSent" boolean DEFAULT false,
    "isMicrosoftParentRecurringEvent" boolean DEFAULT false,
    "eventIdAcrossAllCalendar" character varying(255),
    source character varying(255),
    "sourceId" integer
);
    DROP TABLE public.events;
       public         heap    postgres    false                       1259    39072    open_availabilities    TABLE     c  CREATE TABLE public.open_availabilities (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    datetime character varying(255) NOT NULL,
    booked boolean DEFAULT false NOT NULL,
    "receiverEmail" character varying(255),
    "receiverName" character varying(255),
    "receiverPhone" character varying(255),
    "eventType" character varying(255),
    "senderEmail" character varying(255),
    "emailServiceProvider" character varying(255),
    "meetingLink" text,
    "tagId" integer,
    "eventId" character varying(255),
    status character varying(255),
    "statusId" integer DEFAULT 1,
    comments text,
    "tagTypeId" character varying(255),
    endtime character varying(255),
    "meetingPurpose" character varying(255),
    "isCancelled" boolean DEFAULT false,
    "meetType" integer,
    "guestTimezone" character varying(255),
    "houseNo" character varying(255),
    "houseName" character varying(255),
    street character varying(255),
    area character varying(255),
    state integer,
    city integer,
    pincode character varying(255),
    landmark character varying(255),
    "mapLink" character varying(255),
    "isBookedSlotUpdated" boolean DEFAULT false,
    "isAcceptedByOwner" boolean DEFAULT false,
    "bookedAt" character varying(255),
    "isEmailReminderSent" boolean DEFAULT false,
    "rescheduleReason" character varying(255)
);
 '   DROP TABLE public.open_availabilities;
       public         heap    postgres    false                       1259    38935    users    TABLE     �  CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(255) NOT NULL,
    fullname character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    "emailServiceProvider" character varying(255),
    email2 character varying(255),
    "email2ServiceProvider" character varying(255),
    email3 character varying(255),
    "email3ServiceProvider" character varying(255),
    "userTypeId" integer NOT NULL,
    password character varying(255) NOT NULL,
    "isPasswordUpdated" boolean DEFAULT false NOT NULL,
    "isDeleted" boolean,
    "emailAccessToken" text,
    "emailRefreshToken" text,
    "email2AccessToken" text,
    "email2RefreshToken" text,
    "email3AccessToken" text,
    "email3RefreshToken" text,
    "passwordUpdatedCount" integer DEFAULT 0,
    "temporaryPassword" character varying(255),
    "eventColorForEmail" integer,
    "eventColorForEmail2" integer,
    "eventColorForEmail3" integer,
    "profilePicture" character varying(255),
    "nextSyncTokenForEmail" text,
    "nextSyncTokenForEmail2" text,
    "nextSyncTokenForEmail3" text,
    "lastPasswordUpdatedForSecurity" character varying(255),
    "designationId" integer,
    "organizationId" integer,
    "locationId" integer,
    "timezoneId" integer,
    phonenumber character varying(255),
    phonenumber2 character varying(255),
    phonenumber3 character varying(255),
    phonenumber4 character varying(255),
    phonenumber5 character varying(255),
    "primaryPhonenumber" character varying(255),
    "phonenumberCountryCode" character varying(255),
    "phonenumber2CountryCode" character varying(255),
    "phonenumber3CountryCode" character varying(255),
    "phonenumber4CountryCode" character varying(255),
    "phonenumber5CountryCode" character varying(255),
    theme character varying(255),
    "aboutMeText" text,
    "isNotificationDisabled" boolean DEFAULT false,
    "subscriptionId" integer,
    "baOrgId" integer DEFAULT 1,
    "stripeCustomerId" character varying(255),
    "stripeSubscriptionId" character varying(255),
    "usernameUpdatedCount" integer DEFAULT 0,
    "googleResourceIdEmail1" character varying(255),
    "googleChannelIdEmail1" character varying(255),
    "googleWatchExpirationEmail1" character varying(255),
    "googleResourceIdEmail2" character varying(255),
    "googleChannelIdEmail2" character varying(255),
    "googleWatchExpirationEmail2" character varying(255),
    "googleResourceIdEmail3" character varying(255),
    "googleChannelIdEmail3" character varying(255),
    "googleWatchExpirationEmail3" character varying(255),
    "microsoftSubscriptionIdEmail1" character varying(255),
    "microsoftSubscriptionExpirationEmail1" character varying(255),
    "microsoftSubscriptionIdEmail2" character varying(255),
    "microsoftSubscriptionExpirationEmail2" character varying(255),
    "microsoftSubscriptionIdEmail3" character varying(255),
    "microsoftSubscriptionExpirationEmail3" character varying(255),
    "createdAt" character varying(255),
    "lastLoginTimeStamp" character varying(255),
    "freeSubscriptionExpiration" character varying(255),
    "isFreeTrialOver" boolean DEFAULT false,
    "mfaSecret" character varying(255),
    "mfaEnabled" boolean DEFAULT false,
    "mfaConfigured" boolean DEFAULT false,
    "mfaManditory" boolean DEFAULT false,
    "isCredentialsDisabled" boolean DEFAULT false,
    "emailSyncTimeStamp" character varying(255),
    "email2SyncTimeStamp" character varying(255),
    "email3SyncTimeStamp" character varying(255),
    "credentialDisabledTimeStamp" character varying(255),
    "credentialEnabledTimeStamp" character varying(255),
    "subscriptionUpgradeTimeStamp" character varying(255),
    "subscriptionDowngradeTimeStamp" character varying(255),
    "emailSyncExpiration" character varying(255),
    "email2SyncExpiration" character varying(255),
    "email3SyncExpiration" character varying(255),
    "firstTimeEmailSyncTimeStamp" character varying(255),
    "firstTimeEmail2SyncTimeStamp" character varying(255),
    "firstTimeEmail3SyncTimeStamp" character varying(255),
    "isUsernameUpdated" boolean DEFAULT false,
    business character varying(255),
    industry integer,
    "isMergeCalendarGuideChecked" boolean DEFAULT false
);
    DROP TABLE public.users;
       public         heap    postgres    false            �           1259    51341    event_hub_history_views    VIEW     �  CREATE VIEW public.event_hub_history_views AS
 SELECT DISTINCT ON (e.id) e.id,
    e."eventId",
    e."userId",
    e.title,
    e."startTime",
    e."endTime",
    e."meetingLink",
    e.sender AS "senderEmail",
    e."emailAccount",
    e.attendees,
    e."seriesMasterId",
    e."isDeleted",
    e."isCancelled",
    e."eventIdAcrossAllCalendar",
    e."isMicrosoftParentRecurringEvent",
        CASE
            WHEN (EXISTS ( SELECT 1
               FROM public.users u_1
              WHERE ((u_1.id = e."userId") AND ((lower((u_1.email)::text) = lower((e.sender)::text)) OR (lower((u_1.email2)::text) = lower((e.sender)::text)) OR (lower((u_1.email3)::text) = lower((e.sender)::text)))))) THEN true
            ELSE false
        END AS "creatorFlag",
    COALESCE(av.source, oa.source, eh.source) AS source,
    COALESCE(av."sourceId", oa."sourceId", eh."sourceId") AS "sourceId",
    COALESCE(
        CASE
            WHEN (lower((u.email)::text) = lower((e.sender)::text)) THEN u."emailServiceProvider"
            WHEN (lower((u.email2)::text) = lower((e.sender)::text)) THEN u."email2ServiceProvider"
            WHEN (lower((u.email3)::text) = lower((e.sender)::text)) THEN u."email3ServiceProvider"
            ELSE NULL::character varying
        END,
        CASE
            WHEN (lower((us.email)::text) = lower((e.sender)::text)) THEN us."emailServiceProvider"
            WHEN (lower((us.email2)::text) = lower((e.sender)::text)) THEN us."email2ServiceProvider"
            WHEN (lower((us.email3)::text) = lower((e.sender)::text)) THEN us."email3ServiceProvider"
            ELSE NULL::character varying
        END) AS "senderEmailServiceProvider",
    ((EXTRACT(epoch FROM (to_timestamp((e."endTime")::text, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'::text) - to_timestamp((e."startTime")::text, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'::text))) / (60)::numeric))::integer AS "eventDurationInMinutes",
        CASE
            WHEN (eh."sourceId" IS NOT NULL) THEN eh."eventTypeId"
            ELSE NULL::integer
        END AS "eventTypeId",
        CASE
            WHEN (eh."sourceId" IS NOT NULL) THEN et.value
            ELSE NULL::character varying
        END AS "eventTypeValue",
    eh."meetType"
   FROM ((((((public.events e
     LEFT JOIN ( SELECT 'availabilities'::text AS source,
            availabilities.id AS "sourceId",
            availabilities."meetingLink"
           FROM public.availabilities) av ON ((e."meetingLink" = av."meetingLink")))
     LEFT JOIN ( SELECT 'open_availabilities'::text AS source,
            open_availabilities.id AS "sourceId",
            open_availabilities."meetingLink"
           FROM public.open_availabilities) oa ON ((e."meetingLink" = oa."meetingLink")))
     LEFT JOIN ( SELECT 'event_hub_events'::text AS source,
            event_hub_events.id AS "sourceId",
            event_hub_events."meetingLink",
            event_hub_events."eventTypeId",
            event_hub_events."meetType"
           FROM public.event_hub_events) eh ON ((e."meetingLink" = eh."meetingLink")))
     LEFT JOIN public.event_types et ON ((eh."eventTypeId" = et.id)))
     LEFT JOIN public.users u ON ((u.id = e."userId")))
     LEFT JOIN public.users us ON (((lower((us.email)::text) = lower((e.sender)::text)) OR (lower((us.email2)::text) = lower((e.sender)::text)) OR (lower((us.email3)::text) = lower((e.sender)::text)))))
  WHERE ((e."activeFlag" = true) AND (NOT ((lower((e.sender)::text) <> lower((e."emailAccount")::text)) AND (EXISTS ( SELECT 1
           FROM public.users u_1
          WHERE ((u_1.id = e."userId") AND ((lower((u_1.email)::text) = lower((e.sender)::text)) OR (lower((u_1.email2)::text) = lower((e.sender)::text)) OR (lower((u_1.email3)::text) = lower((e.sender)::text)))))))));
 *   DROP VIEW public.event_hub_history_views;
       public          postgres    false    258    336    336    336    336    334    334    274    274    266    266    266    266    266    266    266    266    266    266    266    266    266    266    266    266    260    260    258    258    258    258    258    258            �           1259    42816    event_merge_calendar_views    VIEW     �  CREATE VIEW public.event_merge_calendar_views AS
 SELECT e.id,
    e."eventId",
    e."userId",
    e.title,
    e."startTime",
    e."endTime",
    e."meetingLink",
    e."emailAccount",
    e.attendees,
    e."isReminderSent",
    e."seriesMasterId",
    e."isMicrosoftParentRecurringEvent",
    u.theme,
    ec1.id AS "eventColorId",
        CASE
            WHEN ((e."emailAccount")::text = (u.email)::text) THEN ec1.color
            WHEN ((e."emailAccount")::text = (u.email2)::text) THEN ec2.color
            WHEN ((e."emailAccount")::text = (u.email3)::text) THEN ec3.color
            ELSE NULL::character varying
        END AS "eventColor",
    e."isDeleted",
    e."isCancelled"
   FROM ((((public.events e
     JOIN public.users u ON ((e."userId" = u.id)))
     LEFT JOIN public.event_colors ec1 ON ((((u.theme)::text = (ec1.theme)::text) AND ((ec1.email_column)::text = 'email'::text))))
     LEFT JOIN public.event_colors ec2 ON ((((u.theme)::text = (ec2.theme)::text) AND ((ec2.email_column)::text = 'email2'::text))))
     LEFT JOIN public.event_colors ec3 ON ((((u.theme)::text = (ec3.theme)::text) AND ((ec3.email_column)::text = 'email3'::text))))
  WHERE (e."activeFlag" = true);
 -   DROP VIEW public.event_merge_calendar_views;
       public          postgres    false    266    266    266    266    266    266    266    266    266    266    266    266    266    258    250    258    250    250    258    258    250    258    266    266            �            1259    24496    event_types_id_seq    SEQUENCE     �   CREATE SEQUENCE public.event_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;
 )   DROP SEQUENCE public.event_types_id_seq;
       public          postgres    false            M           1259    39452    event_types_id_seq1    SEQUENCE     �   CREATE SEQUENCE public.event_types_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.event_types_id_seq1;
       public          postgres    false    334            �           0    0    event_types_id_seq1    SEQUENCE OWNED BY     J   ALTER SEQUENCE public.event_types_id_seq1 OWNED BY public.event_types.id;
          public          postgres    false    333            	           1259    39023    events_id_seq    SEQUENCE     �   CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.events_id_seq;
       public          postgres    false    266            �           0    0    events_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;
          public          postgres    false    265            6           1259    39296    experience_details    TABLE     q  CREATE TABLE public.experience_details (
    id integer NOT NULL,
    "startDate" character varying(255) NOT NULL,
    "endDate" character varying(255),
    "isCurrent" boolean DEFAULT false,
    "userId" integer NOT NULL,
    "organizationId" integer,
    "designationId" integer,
    "userSuggestedOrganizationId" integer,
    "userSuggestedDesignationId" integer
);
 &   DROP TABLE public.experience_details;
       public         heap    postgres    false            5           1259    39295    experience_details_id_seq    SEQUENCE     �   CREATE SEQUENCE public.experience_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.experience_details_id_seq;
       public          postgres    false    310            �           0    0    experience_details_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.experience_details_id_seq OWNED BY public.experience_details.id;
          public          postgres    false    309            �           1259    42052    faq    TABLE     �   CREATE TABLE public.faq (
    id integer NOT NULL,
    question text NOT NULL,
    answer text NOT NULL,
    type character varying(255)
);
    DROP TABLE public.faq;
       public         heap    postgres    false            �           1259    42051 
   faq_id_seq    SEQUENCE     �   CREATE SEQUENCE public.faq_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 !   DROP SEQUENCE public.faq_id_seq;
       public          postgres    false    402            �           0    0 
   faq_id_seq    SEQUENCE OWNED BY     9   ALTER SEQUENCE public.faq_id_seq OWNED BY public.faq.id;
          public          postgres    false    401            J           1259    39415    features_list    TABLE     r   CREATE TABLE public.features_list (
    id integer NOT NULL,
    "featureName" character varying(255) NOT NULL
);
 !   DROP TABLE public.features_list;
       public         heap    postgres    false            I           1259    39414    features_list_id_seq    SEQUENCE     �   CREATE SEQUENCE public.features_list_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.features_list_id_seq;
       public          postgres    false    330            �           0    0    features_list_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.features_list_id_seq OWNED BY public.features_list.id;
          public          postgres    false    329            *           1259    39187    field_of_studies    TABLE     c   CREATE TABLE public.field_of_studies (
    id integer NOT NULL,
    name character varying(255)
);
 $   DROP TABLE public.field_of_studies;
       public         heap    postgres    false            )           1259    39186    field_of_studies_id_seq    SEQUENCE     �   CREATE SEQUENCE public.field_of_studies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.field_of_studies_id_seq;
       public          postgres    false    298            �           0    0    field_of_studies_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.field_of_studies_id_seq OWNED BY public.field_of_studies.id;
          public          postgres    false    297                       1259    39127    open_availability_tags    TABLE     �  CREATE TABLE public.open_availability_tags (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "tagName" character varying(255) NOT NULL,
    "defaultEmail" character varying(255),
    "isDeleted" boolean,
    "openAvailabilityText" character varying(255),
    template text,
    "eventDuration" integer DEFAULT 30,
    "eventTypeId" integer,
    "isAllowedToAddAttendees" boolean DEFAULT false,
    "isEmailDeleted" boolean DEFAULT false,
    image character varying(255),
    title character varying(255),
    "showCommentBox" boolean DEFAULT false,
    "isPrimaryEmailTag" boolean,
    "meetType" integer DEFAULT 1,
    "emailVisibility" boolean DEFAULT false,
    "houseNo" character varying(255),
    "houseName" character varying(255),
    street character varying(255),
    area character varying(255),
    state integer,
    city integer,
    pincode character varying(255),
    landmark character varying(255),
    "mapLink" character varying(255),
    country integer
);
 *   DROP TABLE public.open_availability_tags;
       public         heap    postgres    false            �           1259    41902    frequently_met_people_tags_view    VIEW     	  CREATE VIEW public.frequently_met_people_tags_view AS
 WITH RECURSIVE split_attendees AS (
         SELECT events.id,
            events."eventId",
            events."userId",
            events."emailAccount",
            TRIM(BOTH FROM split_part(events.attendees, ','::text, 1)) AS attendee,
            SUBSTRING(events.attendees FROM (length(TRIM(BOTH FROM split_part(events.attendees, ','::text, 1))) + 2) FOR length(events.attendees)) AS remaining
           FROM public.events
          WHERE (events."activeFlag" = true)
        UNION ALL
         SELECT split_attendees.id,
            split_attendees."eventId",
            split_attendees."userId",
            split_attendees."emailAccount",
            TRIM(BOTH FROM split_part(split_attendees.remaining, ','::text, 1)) AS attendee,
            SUBSTRING(split_attendees.remaining FROM (length(TRIM(BOTH FROM split_part(split_attendees.remaining, ','::text, 1))) + 2) FOR length(split_attendees.remaining)) AS remaining
           FROM split_attendees
          WHERE (split_attendees.remaining <> ''::text)
        ), attendee_counts AS (
         SELECT split_attendees.attendee,
            split_attendees."userId",
            split_attendees."emailAccount",
            count(DISTINCT split_attendees."eventId") AS count
           FROM split_attendees
          GROUP BY split_attendees.attendee, split_attendees."userId", split_attendees."emailAccount"
        ), combined_attendee_counts AS (
         SELECT attendee_counts.attendee,
            attendee_counts."userId",
            sum(attendee_counts.count) AS total_count
           FROM attendee_counts
          GROUP BY attendee_counts.attendee, attendee_counts."userId"
        ), email_account_with_max_count AS (
         SELECT ac.attendee,
            ac."userId",
            ac."emailAccount",
            ac.count
           FROM (attendee_counts ac
             JOIN ( SELECT attendee_counts.attendee,
                    attendee_counts."userId",
                    max(attendee_counts.count) AS max_count
                   FROM attendee_counts
                  GROUP BY attendee_counts.attendee, attendee_counts."userId") max_counts ON (((ac.attendee = max_counts.attendee) AND (ac."userId" = max_counts."userId") AND (ac.count = max_counts.max_count))))
        ), final_attendee_counts AS (
         SELECT eaw.attendee,
            eaw."userId",
            eaw."emailAccount",
            (COALESCE(cac.total_count, (0)::numeric))::integer AS count
           FROM (email_account_with_max_count eaw
             LEFT JOIN combined_attendee_counts cac ON (((eaw.attendee = cac.attendee) AND (eaw."userId" = cac."userId"))))
        ), attendee_ranks AS (
         SELECT final_attendee_counts.attendee,
            final_attendee_counts."userId",
            final_attendee_counts."emailAccount",
            final_attendee_counts.count,
            rank() OVER (PARTITION BY final_attendee_counts."userId" ORDER BY final_attendee_counts.count DESC) AS rank
           FROM final_attendee_counts
        )
 SELECT ar.attendee,
    ar."userId",
    ar."emailAccount",
    ar.count,
    ar.rank,
    oavt."tagName"
   FROM (attendee_ranks ar
     LEFT JOIN public.open_availability_tags oavt ON (((ar."emailAccount")::text = (oavt."defaultEmail")::text)))
  ORDER BY ar."userId", ar.rank;
 2   DROP VIEW public.frequently_met_people_tags_view;
       public          postgres    false    266    266    266    266    284    284    266    266            :           1259    39340    general_templates    TABLE     �   CREATE TABLE public.general_templates (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    template text NOT NULL,
    type character varying(255),
    "predefinedMeetTypeId" integer
);
 %   DROP TABLE public.general_templates;
       public         heap    postgres    false            9           1259    39339    general_templates_id_seq    SEQUENCE     �   CREATE SEQUENCE public.general_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.general_templates_id_seq;
       public          postgres    false    314            �           0    0    general_templates_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.general_templates_id_seq OWNED BY public.general_templates.id;
          public          postgres    false    313            �           1259    39953    group_members    TABLE     h   CREATE TABLE public.group_members (
    "contactId" integer NOT NULL,
    "groupId" integer NOT NULL
);
 !   DROP TABLE public.group_members;
       public         heap    postgres    false            8           1259    39331    groups    TABLE       CREATE TABLE public.groups (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "createdBy" integer NOT NULL,
    "createdAt" character varying(255),
    description character varying(255),
    "adminName" character varying(255),
    "addMe" boolean DEFAULT false
);
    DROP TABLE public.groups;
       public         heap    postgres    false            7           1259    39330    groups_id_seq    SEQUENCE     �   CREATE SEQUENCE public.groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.groups_id_seq;
       public          postgres    false    312            �           0    0    groups_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;
          public          postgres    false    311            �           1259    59936 
   industries    TABLE     ]   CREATE TABLE public.industries (
    id integer NOT NULL,
    name character varying(255)
);
    DROP TABLE public.industries;
       public         heap    postgres    false            �           1259    59935    industries_id_seq    SEQUENCE     �   CREATE SEQUENCE public.industries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.industries_id_seq;
       public          postgres    false    434            �           0    0    industries_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.industries_id_seq OWNED BY public.industries.id;
          public          postgres    false    433                        1259    39150    institution    TABLE     k   CREATE TABLE public.institution (
    id integer NOT NULL,
    "institutionName" character varying(255)
);
    DROP TABLE public.institution;
       public         heap    postgres    false                       1259    39149    institution_id_seq    SEQUENCE     �   CREATE SEQUENCE public.institution_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.institution_id_seq;
       public          postgres    false    288            �           0    0    institution_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.institution_id_seq OWNED BY public.institution.id;
          public          postgres    false    287                        1259    38919 	   locations    TABLE     `   CREATE TABLE public.locations (
    id integer NOT NULL,
    location character varying(255)
);
    DROP TABLE public.locations;
       public         heap    postgres    false            �            1259    38918    locations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.locations_id_seq;
       public          postgres    false    256            �           0    0    locations_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;
          public          postgres    false    255            �           1259    41135    notifications    TABLE     B  CREATE TABLE public.notifications (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    description text,
    datetime character varying(255),
    "createdAt" character varying(255),
    type character varying(255),
    "isRead" boolean DEFAULT false,
    "meetingLink" character varying(255),
    creator boolean DEFAULT false,
    "eventId" character varying(255),
    title character varying(255),
    source character varying(255),
    "openAvailabilityId" integer,
    "emailAccount" character varying(255),
    "eventIdAcrossAllCalendar" character varying(255)
);
 !   DROP TABLE public.notifications;
       public         heap    postgres    false            �           1259    41134    notifications_id_seq    SEQUENCE     �   CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.notifications_id_seq;
       public          postgres    false    397            �           0    0    notifications_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;
          public          postgres    false    396                       1259    39071    open_availabilities_id_seq    SEQUENCE     �   CREATE SEQUENCE public.open_availabilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.open_availabilities_id_seq;
       public          postgres    false    274            �           0    0    open_availabilities_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.open_availabilities_id_seq OWNED BY public.open_availabilities.id;
          public          postgres    false    273            �           1259    39920    open_availability_feedbacks    TABLE     �   CREATE TABLE public.open_availability_feedbacks (
    id integer NOT NULL,
    "openAvailabilityId" integer NOT NULL,
    question character varying(255) NOT NULL,
    answer character varying(255) NOT NULL,
    type character varying(255)
);
 /   DROP TABLE public.open_availability_feedbacks;
       public         heap    postgres    false            �           1259    39919 "   open_availability_feedbacks_id_seq    SEQUENCE     �   CREATE SEQUENCE public.open_availability_feedbacks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public.open_availability_feedbacks_id_seq;
       public          postgres    false    388            �           0    0 "   open_availability_feedbacks_id_seq    SEQUENCE OWNED BY     i   ALTER SEQUENCE public.open_availability_feedbacks_id_seq OWNED BY public.open_availability_feedbacks.id;
          public          postgres    false    387            �           1259    39834    open_availability_questions    TABLE     �   CREATE TABLE public.open_availability_questions (
    "openAvailabilityTagId" integer NOT NULL,
    "questionId" integer NOT NULL,
    required boolean DEFAULT false
);
 /   DROP TABLE public.open_availability_questions;
       public         heap    postgres    false            �           1259    39908 &   open_availability_questions_change_log    TABLE     �   CREATE TABLE public.open_availability_questions_change_log (
    id integer NOT NULL,
    "openAvailabilityTagId" integer,
    "questionId" integer,
    "addedTime" character varying DEFAULT CURRENT_TIMESTAMP
);
 :   DROP TABLE public.open_availability_questions_change_log;
       public         heap    postgres    false            �           1259    39907 -   open_availability_questions_change_log_id_seq    SEQUENCE     �   CREATE SEQUENCE public.open_availability_questions_change_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 D   DROP SEQUENCE public.open_availability_questions_change_log_id_seq;
       public          postgres    false    386            �           0    0 -   open_availability_questions_change_log_id_seq    SEQUENCE OWNED BY        ALTER SEQUENCE public.open_availability_questions_change_log_id_seq OWNED BY public.open_availability_questions_change_log.id;
          public          postgres    false    385            �           1259    40384 #   open_availability_tag_verifications    TABLE       CREATE TABLE public.open_availability_tag_verifications (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "tagId" integer NOT NULL,
    datetime character varying(255),
    count integer DEFAULT 0,
    email character varying(255),
    "parsedDate" character varying(255)
);
 7   DROP TABLE public.open_availability_tag_verifications;
       public         heap    postgres    false            �           1259    40383 *   open_availability_tag_verifications_id_seq    SEQUENCE     �   CREATE SEQUENCE public.open_availability_tag_verifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 A   DROP SEQUENCE public.open_availability_tag_verifications_id_seq;
       public          postgres    false    395            �           0    0 *   open_availability_tag_verifications_id_seq    SEQUENCE OWNED BY     y   ALTER SEQUENCE public.open_availability_tag_verifications_id_seq OWNED BY public.open_availability_tag_verifications.id;
          public          postgres    false    394                       1259    39126    open_availability_tags_id_seq    SEQUENCE     �   CREATE SEQUENCE public.open_availability_tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.open_availability_tags_id_seq;
       public          postgres    false    284            �           0    0    open_availability_tags_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.open_availability_tags_id_seq OWNED BY public.open_availability_tags.id;
          public          postgres    false    283            �           1259    40316    org_tab_names    TABLE     �   CREATE TABLE public.org_tab_names (
    id integer NOT NULL,
    "tabId" integer NOT NULL,
    "orgId" integer NOT NULL,
    "tabNameOrgGiven" character varying(255) NOT NULL
);
 !   DROP TABLE public.org_tab_names;
       public         heap    postgres    false            �           1259    40315    org_tab_names_id_seq    SEQUENCE     �   CREATE SEQUENCE public.org_tab_names_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.org_tab_names_id_seq;
       public          postgres    false    391            �           0    0    org_tab_names_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.org_tab_names_id_seq OWNED BY public.org_tab_names.id;
          public          postgres    false    390            �           1259    42390    organization_resources    TABLE     �   CREATE TABLE public.organization_resources (
    id integer NOT NULL,
    "orgId" character varying(9) NOT NULL,
    "apiKey" character varying(255) NOT NULL,
    "resourceId" integer NOT NULL,
    "orgSecretKey" character varying(255) NOT NULL
);
 *   DROP TABLE public.organization_resources;
       public         heap    postgres    false            �           1259    42389    organization_resources_id_seq    SEQUENCE     �   CREATE SEQUENCE public.organization_resources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.organization_resources_id_seq;
       public          postgres    false    410            �           0    0    organization_resources_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.organization_resources_id_seq OWNED BY public.organization_resources.id;
          public          postgres    false    409            �            1259    38912    organizations    TABLE     h   CREATE TABLE public.organizations (
    id integer NOT NULL,
    organization character varying(255)
);
 !   DROP TABLE public.organizations;
       public         heap    postgres    false            �            1259    38911    organizations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.organizations_id_seq;
       public          postgres    false    254            �           0    0    organizations_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;
          public          postgres    false    253                       1259    39050    otps    TABLE     r   CREATE TABLE public.otps (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    otp integer
);
    DROP TABLE public.otps;
       public         heap    postgres    false                       1259    39049    otps_id_seq    SEQUENCE     �   CREATE SEQUENCE public.otps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.otps_id_seq;
       public          postgres    false    270            �           0    0    otps_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.otps_id_seq OWNED BY public.otps.id;
          public          postgres    false    269                       1259    39096    password_verification_keys    TABLE     �   CREATE TABLE public.password_verification_keys (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "passwordVerificationKey" character varying(255) NOT NULL
);
 .   DROP TABLE public.password_verification_keys;
       public         heap    postgres    false                       1259    39095 !   password_verification_keys_id_seq    SEQUENCE     �   CREATE SEQUENCE public.password_verification_keys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.password_verification_keys_id_seq;
       public          postgres    false    278            �           0    0 !   password_verification_keys_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.password_verification_keys_id_seq OWNED BY public.password_verification_keys.id;
          public          postgres    false    277            �            1259    22450    power_bi_reports_seq    SEQUENCE     �   CREATE SEQUENCE public.power_bi_reports_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 442424242442
    CACHE 1;
 +   DROP SEQUENCE public.power_bi_reports_seq;
       public          postgres    false            F           1259    39394    powerbi_reports    TABLE     �   CREATE TABLE public.powerbi_reports (
    id integer NOT NULL,
    "reportId" character varying(255),
    "userTypeId" integer,
    parameters character varying(255)
);
 #   DROP TABLE public.powerbi_reports;
       public         heap    postgres    false            E           1259    39393    powerbi_reports_id_seq    SEQUENCE     �   CREATE SEQUENCE public.powerbi_reports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.powerbi_reports_id_seq;
       public          postgres    false    326            �           0    0    powerbi_reports_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.powerbi_reports_id_seq OWNED BY public.powerbi_reports.id;
          public          postgres    false    325            D           1259    39385    predefined_events    TABLE     ;  CREATE TABLE public.predefined_events (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    title character varying(255) NOT NULL,
    "requiredGuests" character varying(255) NOT NULL,
    "optionalGuests" character varying(255) NOT NULL,
    "startTime" character varying(255) NOT NULL,
    "eventTime" integer NOT NULL,
    "senderEmail" character varying(255) NOT NULL,
    template text NOT NULL,
    "eventTypeId" integer,
    "groupId" character varying(255),
    count integer,
    "predefinedMeetId" integer,
    "isEmailDeleted" boolean DEFAULT false
);
 %   DROP TABLE public.predefined_events;
       public         heap    postgres    false            C           1259    39384    predefined_events_id_seq    SEQUENCE     �   CREATE SEQUENCE public.predefined_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.predefined_events_id_seq;
       public          postgres    false    324            �           0    0    predefined_events_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.predefined_events_id_seq OWNED BY public.predefined_events.id;
          public          postgres    false    323            T           1259    39479    predefined_meet_locations    TABLE     v   CREATE TABLE public.predefined_meet_locations (
    id integer NOT NULL,
    value character varying(255) NOT NULL
);
 -   DROP TABLE public.predefined_meet_locations;
       public         heap    postgres    false            S           1259    39478     predefined_meet_locations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.predefined_meet_locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.predefined_meet_locations_id_seq;
       public          postgres    false    340            �           0    0     predefined_meet_locations_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.predefined_meet_locations_id_seq OWNED BY public.predefined_meet_locations.id;
          public          postgres    false    339            V           1259    39486    predefined_meet_types    TABLE     r   CREATE TABLE public.predefined_meet_types (
    id integer NOT NULL,
    value character varying(255) NOT NULL
);
 )   DROP TABLE public.predefined_meet_types;
       public         heap    postgres    false            U           1259    39485    predefined_meet_types_id_seq    SEQUENCE     �   CREATE SEQUENCE public.predefined_meet_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.predefined_meet_types_id_seq;
       public          postgres    false    342            �           0    0    predefined_meet_types_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.predefined_meet_types_id_seq OWNED BY public.predefined_meet_types.id;
          public          postgres    false    341            R           1259    39470    predefined_meets    TABLE     -  CREATE TABLE public.predefined_meets (
    id integer NOT NULL,
    "userId" integer,
    title character varying(255),
    type integer,
    location integer,
    url character varying(255),
    address character varying(255),
    phone character varying(255),
    passcode character varying(255)
);
 $   DROP TABLE public.predefined_meets;
       public         heap    postgres    false            Q           1259    39469    predefined_meets_id_seq    SEQUENCE     �   CREATE SEQUENCE public.predefined_meets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.predefined_meets_id_seq;
       public          postgres    false    338            �           0    0    predefined_meets_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.predefined_meets_id_seq OWNED BY public.predefined_meets.id;
          public          postgres    false    337            \           1259    39511    projects    TABLE       CREATE TABLE public.projects (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "projectName" character varying(255) NOT NULL,
    "startDate" character varying(255) NOT NULL,
    "endDate" character varying(255) NOT NULL,
    "defaultHours" integer
);
    DROP TABLE public.projects;
       public         heap    postgres    false            [           1259    39510    projects_id_seq    SEQUENCE     �   CREATE SEQUENCE public.projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.projects_id_seq;
       public          postgres    false    348            �           0    0    projects_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;
          public          postgres    false    347            �           1259    43014    propose_new_times    TABLE     r  CREATE TABLE public.propose_new_times (
    id integer NOT NULL,
    "eventId" character varying(255),
    email character varying(255),
    "startTime" character varying(255),
    "endTime" character varying(255),
    comment character varying(255),
    "isRejected" boolean DEFAULT false,
    "userId" integer,
    "eventIdAcrossAllCalendar" character varying(255)
);
 %   DROP TABLE public.propose_new_times;
       public         heap    postgres    false            �           1259    43013    propose_new_times_id_seq    SEQUENCE     �   CREATE SEQUENCE public.propose_new_times_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.propose_new_times_id_seq;
       public          postgres    false    427            �           0    0    propose_new_times_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.propose_new_times_id_seq OWNED BY public.propose_new_times.id;
          public          postgres    false    426            Z           1259    39502 	   questions    TABLE     K  CREATE TABLE public.questions (
    id integer NOT NULL,
    question character varying(255),
    "userId" integer,
    type character varying(255),
    option1 character varying(255),
    option2 character varying(255),
    option3 character varying(255),
    option4 character varying(255),
    option5 character varying(255)
);
    DROP TABLE public.questions;
       public         heap    postgres    false            Y           1259    39501    questions_id_seq    SEQUENCE     �   CREATE SEQUENCE public.questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.questions_id_seq;
       public          postgres    false    346            �           0    0    questions_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.questions_id_seq OWNED BY public.questions.id;
          public          postgres    false    345            �           1259    42383 	   resources    TABLE     y   CREATE TABLE public.resources (
    "resourceId" integer NOT NULL,
    "resourceName" character varying(255) NOT NULL
);
    DROP TABLE public.resources;
       public         heap    postgres    false            �           1259    42382    resources_resourceId_seq    SEQUENCE     �   CREATE SEQUENCE public."resources_resourceId_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public."resources_resourceId_seq";
       public          postgres    false    408            �           0    0    resources_resourceId_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public."resources_resourceId_seq" OWNED BY public.resources."resourceId";
          public          postgres    false    407                       1259    39017    secondary_skills    TABLE     |   CREATE TABLE public.secondary_skills (
    id integer NOT NULL,
    "secondarySkillName" character varying(255) NOT NULL
);
 $   DROP TABLE public.secondary_skills;
       public         heap    postgres    false                       1259    39016    secondary_skills_id_seq    SEQUENCE     �   CREATE SEQUENCE public.secondary_skills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.secondary_skills_id_seq;
       public          postgres    false    264            �           0    0    secondary_skills_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.secondary_skills_id_seq OWNED BY public.secondary_skills.id;
          public          postgres    false    263            u           1259    39654    skill_secondary_skills    TABLE     x   CREATE TABLE public.skill_secondary_skills (
    "skillId" integer NOT NULL,
    "secondarySkillId" integer NOT NULL
);
 *   DROP TABLE public.skill_secondary_skills;
       public         heap    postgres    false            z           1259    39729    skill_zoho_forms    TABLE     l   CREATE TABLE public.skill_zoho_forms (
    "skillId" integer NOT NULL,
    "zohoFormId" integer NOT NULL
);
 $   DROP TABLE public.skill_zoho_forms;
       public         heap    postgres    false                       1259    39010    skills    TABLE     i   CREATE TABLE public.skills (
    id integer NOT NULL,
    "skillName" character varying(255) NOT NULL
);
    DROP TABLE public.skills;
       public         heap    postgres    false                       1259    39009    skills_id_seq    SEQUENCE     �   CREATE SEQUENCE public.skills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.skills_id_seq;
       public          postgres    false    262            �           0    0    skills_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.skills_id_seq OWNED BY public.skills.id;
          public          postgres    false    261            .           1259    39246    states    TABLE     r   CREATE TABLE public.states (
    id integer NOT NULL,
    name character varying(255),
    "countryId" integer
);
    DROP TABLE public.states;
       public         heap    postgres    false            -           1259    39245    states_id_seq    SEQUENCE     �   CREATE SEQUENCE public.states_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.states_id_seq;
       public          postgres    false    302            �           0    0    states_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.states_id_seq OWNED BY public.states.id;
          public          postgres    false    301            �           1259    41947    status    TABLE     [   CREATE TABLE public.status (
    id integer NOT NULL,
    status character varying(255)
);
    DROP TABLE public.status;
       public         heap    postgres    false            �           1259    41946    status_id_seq    SEQUENCE     �   CREATE SEQUENCE public.status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.status_id_seq;
       public          postgres    false    400            �           0    0    status_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.status_id_seq OWNED BY public.status.id;
          public          postgres    false    399            �           1259    42077    subscription_features    TABLE     �   CREATE TABLE public.subscription_features (
    id integer NOT NULL,
    "featureId" integer NOT NULL,
    "subscriptionId" integer NOT NULL,
    availability character varying(255) NOT NULL
);
 )   DROP TABLE public.subscription_features;
       public         heap    postgres    false            �           1259    42076    subscription_features_id_seq    SEQUENCE     �   CREATE SEQUENCE public.subscription_features_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.subscription_features_id_seq;
       public          postgres    false    404            �           0    0    subscription_features_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.subscription_features_id_seq OWNED BY public.subscription_features.id;
          public          postgres    false    403            <           1259    39349    subscriptions    TABLE     �   CREATE TABLE public.subscriptions (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    price integer,
    "monthlyPriceId" character varying(255),
    "yearlyPriceId" character varying(255),
    text character varying(255)
);
 !   DROP TABLE public.subscriptions;
       public         heap    postgres    false            ;           1259    39348    subscriptions_id_seq    SEQUENCE     �   CREATE SEQUENCE public.subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.subscriptions_id_seq;
       public          postgres    false    316            �           0    0    subscriptions_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;
          public          postgres    false    315            L           1259    39434 	   tab_names    TABLE     �   CREATE TABLE public.tab_names (
    id integer NOT NULL,
    "userTypeId" integer NOT NULL,
    "tabName" character varying(255) NOT NULL
);
    DROP TABLE public.tab_names;
       public         heap    postgres    false            K           1259    39433    tab_names_id_seq    SEQUENCE     �   CREATE SEQUENCE public.tab_names_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.tab_names_id_seq;
       public          postgres    false    332            �           0    0    tab_names_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.tab_names_id_seq OWNED BY public.tab_names.id;
          public          postgres    false    331            �           1259    42546    tabs    TABLE     �   CREATE TABLE public.tabs (
    id integer NOT NULL,
    "tabNumbering" integer NOT NULL,
    "tabName" character varying(255) NOT NULL,
    description character varying(255)
);
    DROP TABLE public.tabs;
       public         heap    postgres    false            �           1259    42545    tabs_id_seq    SEQUENCE     �   CREATE SEQUENCE public.tabs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.tabs_id_seq;
       public          postgres    false    420            �           0    0    tabs_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.tabs_id_seq OWNED BY public.tabs.id;
          public          postgres    false    419            �           1259    42467    tag_link_types    TABLE     �   CREATE TABLE public.tag_link_types (
    id integer NOT NULL,
    "typeId" character varying(255),
    name character varying(255)
);
 "   DROP TABLE public.tag_link_types;
       public         heap    postgres    false            �           1259    42466    tag_link_types_id_seq    SEQUENCE     �   CREATE SEQUENCE public.tag_link_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.tag_link_types_id_seq;
       public          postgres    false    412            �           0    0    tag_link_types_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.tag_link_types_id_seq OWNED BY public.tag_link_types.id;
          public          postgres    false    411                       1259    39819    tag_members    TABLE     q   CREATE TABLE public.tag_members (
    "openAvailabilityTagId" integer NOT NULL,
    "userId" integer NOT NULL
);
    DROP TABLE public.tag_members;
       public         heap    postgres    false            ^           1259    39520 
   timesheets    TABLE     O  CREATE TABLE public.timesheets (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "projectId" integer NOT NULL,
    "weekStartDate" character varying(255) NOT NULL,
    "weekEndDate" character varying(255) NOT NULL,
    "totalHours" integer NOT NULL,
    status character varying(255),
    remarks character varying(255)
);
    DROP TABLE public.timesheets;
       public         heap    postgres    false            ]           1259    39519    timesheets_id_seq    SEQUENCE     �   CREATE SEQUENCE public.timesheets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.timesheets_id_seq;
       public          postgres    false    350            �           0    0    timesheets_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.timesheets_id_seq OWNED BY public.timesheets.id;
          public          postgres    false    349            �           1259    68192 	   timezones    TABLE     �   CREATE TABLE public.timezones (
    id integer NOT NULL,
    timezone character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    abbreviation character varying(255) NOT NULL
);
    DROP TABLE public.timezones;
       public         heap    postgres    false            �           1259    68191    timezones_id_seq    SEQUENCE     �   CREATE SEQUENCE public.timezones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.timezones_id_seq;
       public          postgres    false    436            �           0    0    timezones_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.timezones_id_seq OWNED BY public.timezones.id;
          public          postgres    false    435            w           1259    39684    tp_secondary_skills    TABLE     t   CREATE TABLE public.tp_secondary_skills (
    "userId" integer NOT NULL,
    "secondarySkillId" integer NOT NULL
);
 '   DROP TABLE public.tp_secondary_skills;
       public         heap    postgres    false            v           1259    39669 	   tp_skills    TABLE     a   CREATE TABLE public.tp_skills (
    "userId" integer NOT NULL,
    "skillId" integer NOT NULL
);
    DROP TABLE public.tp_skills;
       public         heap    postgres    false                       1259    39120 (   user_associated_general_secondary_skills    TABLE     �   CREATE TABLE public.user_associated_general_secondary_skills (
    id integer NOT NULL,
    "secondarySkillName" character varying(255) NOT NULL,
    "userId" integer NOT NULL
);
 <   DROP TABLE public.user_associated_general_secondary_skills;
       public         heap    postgres    false                       1259    39119 /   user_associated_general_secondary_skills_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_associated_general_secondary_skills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 F   DROP SEQUENCE public.user_associated_general_secondary_skills_id_seq;
       public          postgres    false    282            �           0    0 /   user_associated_general_secondary_skills_id_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public.user_associated_general_secondary_skills_id_seq OWNED BY public.user_associated_general_secondary_skills.id;
          public          postgres    false    281                       1259    39113    user_associated_general_skills    TABLE     �   CREATE TABLE public.user_associated_general_skills (
    id integer NOT NULL,
    "skillName" character varying(255) NOT NULL,
    "userId" integer NOT NULL
);
 2   DROP TABLE public.user_associated_general_skills;
       public         heap    postgres    false                       1259    39112 %   user_associated_general_skills_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_associated_general_skills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 <   DROP SEQUENCE public.user_associated_general_skills_id_seq;
       public          postgres    false    280            �           0    0 %   user_associated_general_skills_id_seq    SEQUENCE OWNED BY     o   ALTER SEQUENCE public.user_associated_general_skills_id_seq OWNED BY public.user_associated_general_skills.id;
          public          postgres    false    279            H           1259    39403    user_current_location    TABLE     �   CREATE TABLE public.user_current_location (
    id integer NOT NULL,
    "userId" integer,
    "currentCityId" integer,
    "addedTime" timestamp with time zone
);
 )   DROP TABLE public.user_current_location;
       public         heap    postgres    false            G           1259    39402    user_current_location_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_current_location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.user_current_location_id_seq;
       public          postgres    false    328            �           0    0    user_current_location_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.user_current_location_id_seq OWNED BY public.user_current_location.id;
          public          postgres    false    327            B           1259    39376    user_defined_email_templates    TABLE     �   CREATE TABLE public.user_defined_email_templates (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    name character varying(255),
    template text,
    type character varying(255),
    "predefinedMeetTypeId" integer
);
 0   DROP TABLE public.user_defined_email_templates;
       public         heap    postgres    false            A           1259    39375 #   user_defined_email_templates_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_defined_email_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE public.user_defined_email_templates_id_seq;
       public          postgres    false    322            �           0    0 #   user_defined_email_templates_id_seq    SEQUENCE OWNED BY     k   ALTER SEQUENCE public.user_defined_email_templates_id_seq OWNED BY public.user_defined_email_templates.id;
          public          postgres    false    321            �           1259    40334    user_email_signature    TABLE       CREATE TABLE public.user_email_signature (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    title character varying(255) NOT NULL,
    fullname character varying(255),
    phonenumber character varying(255),
    "organizationId" integer,
    website character varying(255)
);
 (   DROP TABLE public.user_email_signature;
       public         heap    postgres    false            �           1259    40333    user_email_signature_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_email_signature_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.user_email_signature_id_seq;
       public          postgres    false    393            �           0    0    user_email_signature_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.user_email_signature_id_seq OWNED BY public.user_email_signature.id;
          public          postgres    false    392            ~           1259    39789    user_general_secondary_skills    TABLE     ~   CREATE TABLE public.user_general_secondary_skills (
    "userId" integer NOT NULL,
    "secondarySkillId" integer NOT NULL
);
 1   DROP TABLE public.user_general_secondary_skills;
       public         heap    postgres    false            }           1259    39774    user_general_skills    TABLE     k   CREATE TABLE public.user_general_skills (
    "userId" integer NOT NULL,
    "skillId" integer NOT NULL
);
 '   DROP TABLE public.user_general_skills;
       public         heap    postgres    false                       1259    39087    user_ips    TABLE     �   CREATE TABLE public.user_ips (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    ip character varying(255),
    "loggedTime" character varying(255),
    "ipLocation" character varying(255)
);
    DROP TABLE public.user_ips;
       public         heap    postgres    false                       1259    39086    user_ips_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_ips_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.user_ips_id_seq;
       public          postgres    false    276            �           0    0    user_ips_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.user_ips_id_seq OWNED BY public.user_ips.id;
          public          postgres    false    275            �           1259    42870    user_login_logs    TABLE     D  CREATE TABLE public.user_login_logs (
    id integer NOT NULL,
    "userId" integer,
    "createdAt" character varying(255),
    "isCredentialsDisabled" boolean,
    "credentialDisabledTimeStamp" character varying(255),
    "credentialEnabledTimeStamp" character varying(255),
    "lastLoginTried" character varying(255)
);
 #   DROP TABLE public.user_login_logs;
       public         heap    postgres    false            �           1259    42869    user_login_logs_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_login_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.user_login_logs_id_seq;
       public          postgres    false    425            �           0    0    user_login_logs_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.user_login_logs_id_seq OWNED BY public.user_login_logs.id;
          public          postgres    false    424                       1259    39138    user_personality_traits    TABLE     �   CREATE TABLE public.user_personality_traits (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    collaboration integer,
    communication integer,
    "criticalThinking" integer,
    resilience integer,
    empathy integer
);
 +   DROP TABLE public.user_personality_traits;
       public         heap    postgres    false                       1259    39137    user_personality_traits_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_personality_traits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.user_personality_traits_id_seq;
       public          postgres    false    286            �           0    0    user_personality_traits_id_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.user_personality_traits_id_seq OWNED BY public.user_personality_traits.id;
          public          postgres    false    285            &           1259    39173    user_suggested_course    TABLE     �   CREATE TABLE public.user_suggested_course (
    id integer NOT NULL,
    course integer NOT NULL,
    "userId" integer NOT NULL,
    "educationLevelId" integer,
    "fieldOfStudy" character varying(255)
);
 )   DROP TABLE public.user_suggested_course;
       public         heap    postgres    false            %           1259    39172    user_suggested_course_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_suggested_course_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.user_suggested_course_id_seq;
       public          postgres    false    294            �           0    0    user_suggested_course_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.user_suggested_course_id_seq OWNED BY public.user_suggested_course.id;
          public          postgres    false    293            4           1259    39289    user_suggested_designation    TABLE     �   CREATE TABLE public.user_suggested_designation (
    id integer NOT NULL,
    designation character varying(255) NOT NULL,
    "userId" integer NOT NULL
);
 .   DROP TABLE public.user_suggested_designation;
       public         heap    postgres    false            3           1259    39288 !   user_suggested_designation_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_suggested_designation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.user_suggested_designation_id_seq;
       public          postgres    false    308            �           0    0 !   user_suggested_designation_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.user_suggested_designation_id_seq OWNED BY public.user_suggested_designation.id;
          public          postgres    false    307            $           1259    39164    user_suggested_institution    TABLE       CREATE TABLE public.user_suggested_institution (
    id integer NOT NULL,
    "institutionName" character varying(255) NOT NULL,
    "userId" integer NOT NULL,
    website character varying(255),
    "cityId" integer,
    "stateId" integer,
    "countryId" integer
);
 .   DROP TABLE public.user_suggested_institution;
       public         heap    postgres    false            #           1259    39163 !   user_suggested_institution_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_suggested_institution_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.user_suggested_institution_id_seq;
       public          postgres    false    292            �           0    0 !   user_suggested_institution_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.user_suggested_institution_id_seq OWNED BY public.user_suggested_institution.id;
          public          postgres    false    291            2           1259    39270    user_suggested_organization    TABLE     J  CREATE TABLE public.user_suggested_organization (
    id integer NOT NULL,
    "organizationName" character varying(255) NOT NULL,
    "userId" integer NOT NULL,
    website character varying(255) NOT NULL,
    "linkedinUrl" character varying(255),
    "cityId" integer,
    "stateId" integer,
    "countryId" integer NOT NULL
);
 /   DROP TABLE public.user_suggested_organization;
       public         heap    postgres    false            1           1259    39269 "   user_suggested_organization_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_suggested_organization_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public.user_suggested_organization_id_seq;
       public          postgres    false    306            �           0    0 "   user_suggested_organization_id_seq    SEQUENCE OWNED BY     i   ALTER SEQUENCE public.user_suggested_organization_id_seq OWNED BY public.user_suggested_organization.id;
          public          postgres    false    305            �           1259    42526    user_tab_activities    TABLE     �   CREATE TABLE public.user_tab_activities (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    "tabId" integer NOT NULL,
    "startTime" character varying(255) NOT NULL,
    "endTime" character varying(255)
);
 '   DROP TABLE public.user_tab_activities;
       public         heap    postgres    false            �           1259    42525    user_tab_activities_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_tab_activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.user_tab_activities_id_seq;
       public          postgres    false    418            �           0    0    user_tab_activities_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.user_tab_activities_id_seq OWNED BY public.user_tab_activities.id;
          public          postgres    false    417            �            1259    38889 
   user_types    TABLE     l   CREATE TABLE public.user_types (
    id integer NOT NULL,
    "userType" character varying(255) NOT NULL
);
    DROP TABLE public.user_types;
       public         heap    postgres    false            �            1259    38888    user_types_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.user_types_id_seq;
       public          postgres    false    248            �           0    0    user_types_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.user_types_id_seq OWNED BY public.user_types.id;
          public          postgres    false    247                       1259    39057    user_verifications    TABLE     �   CREATE TABLE public.user_verifications (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    email character varying(255) NOT NULL,
    "isAccountVerified" boolean DEFAULT false NOT NULL,
    "accountVerifyKey" character varying(255)
);
 &   DROP TABLE public.user_verifications;
       public         heap    postgres    false                       1259    39056    user_verifications_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_verifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.user_verifications_id_seq;
       public          postgres    false    272            �           0    0    user_verifications_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.user_verifications_id_seq OWNED BY public.user_verifications.id;
          public          postgres    false    271                       1259    38934    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public          postgres    false    258            �           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public          postgres    false    257                       1259    39041 
   zoho_forms    TABLE     �   CREATE TABLE public.zoho_forms (
    id integer NOT NULL,
    "formName" character varying(255) NOT NULL,
    link character varying(255) NOT NULL
);
    DROP TABLE public.zoho_forms;
       public         heap    postgres    false                       1259    39040    zoho_forms_id_seq    SEQUENCE     �   CREATE SEQUENCE public.zoho_forms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.zoho_forms_id_seq;
       public          postgres    false    268            �           0    0    zoho_forms_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.zoho_forms_id_seq OWNED BY public.zoho_forms.id;
          public          postgres    false    267            {           2604    38997    availabilities id    DEFAULT     v   ALTER TABLE ONLY public.availabilities ALTER COLUMN id SET DEFAULT nextval('public.availabilities_id_seq'::regclass);
 @   ALTER TABLE public.availabilities ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    260    259    260            �           2604    39361    ba_organizations id    DEFAULT     z   ALTER TABLE ONLY public.ba_organizations ALTER COLUMN id SET DEFAULT nextval('public.ba_organizations_id_seq'::regclass);
 B   ALTER TABLE public.ba_organizations ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    317    318    318            �           2604    51354 %   blocked_email_by_slot_broadcasters id    DEFAULT     �   ALTER TABLE ONLY public.blocked_email_by_slot_broadcasters ALTER COLUMN id SET DEFAULT nextval('public.blocked_email_by_slot_broadcasters_id_seq'::regclass);
 T   ALTER TABLE public.blocked_email_by_slot_broadcasters ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    430    429    430            �           2604    39261 	   cities id    DEFAULT     f   ALTER TABLE ONLY public.cities ALTER COLUMN id SET DEFAULT nextval('public.cities_id_seq'::regclass);
 8   ALTER TABLE public.cities ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    304    303    304            �           2604    39496    contacts id    DEFAULT     j   ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);
 :   ALTER TABLE public.contacts ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    344    343    344            �           2604    76321    countries id    DEFAULT     l   ALTER TABLE ONLY public.countries ALTER COLUMN id SET DEFAULT nextval('public.countries_id_seq'::regclass);
 ;   ALTER TABLE public.countries ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    437    438    438            �           2604    39160 	   course id    DEFAULT     f   ALTER TABLE ONLY public.course ALTER COLUMN id SET DEFAULT nextval('public.course_id_seq'::regclass);
 8   ALTER TABLE public.course ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    290    289    290            �           2604    42564    credential_blocked_logs id    DEFAULT     �   ALTER TABLE ONLY public.credential_blocked_logs ALTER COLUMN id SET DEFAULT nextval('public.credential_blocked_logs_id_seq'::regclass);
 I   ALTER TABLE public.credential_blocked_logs ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    422    421    422            �           2604    39546 $   crm_internal_communication_status id    DEFAULT     �   ALTER TABLE ONLY public.crm_internal_communication_status ALTER COLUMN id SET DEFAULT nextval('public.crm_internal_communication_status_id_seq'::regclass);
 S   ALTER TABLE public.crm_internal_communication_status ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    354    353    354            �           2604    39630 *   crm_internal_email_communication_status id    DEFAULT     �   ALTER TABLE ONLY public.crm_internal_email_communication_status ALTER COLUMN id SET DEFAULT nextval('public.crm_internal_email_communication_status_id_seq'::regclass);
 Y   ALTER TABLE public.crm_internal_email_communication_status ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    365    366    366            �           2604    39592 "   crm_internal_lead_company_infos id    DEFAULT     �   ALTER TABLE ONLY public.crm_internal_lead_company_infos ALTER COLUMN id SET DEFAULT nextval('public.crm_internal_lead_company_infos_id_seq'::regclass);
 Q   ALTER TABLE public.crm_internal_lead_company_infos ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    359    360    360            �           2604    39570 "   crm_internal_lead_contact_infos id    DEFAULT     �   ALTER TABLE ONLY public.crm_internal_lead_contact_infos ALTER COLUMN id SET DEFAULT nextval('public.crm_internal_lead_contact_infos_id_seq'::regclass);
 Q   ALTER TABLE public.crm_internal_lead_contact_infos ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    357    358    358            �           2604    39553    crm_internal_lead_infos id    DEFAULT     �   ALTER TABLE ONLY public.crm_internal_lead_infos ALTER COLUMN id SET DEFAULT nextval('public.crm_internal_lead_infos_id_seq'::regclass);
 I   ALTER TABLE public.crm_internal_lead_infos ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    356    355    356            �           2604    39606    crm_internal_lead_notes id    DEFAULT     �   ALTER TABLE ONLY public.crm_internal_lead_notes ALTER COLUMN id SET DEFAULT nextval('public.crm_internal_lead_notes_id_seq'::regclass);
 I   ALTER TABLE public.crm_internal_lead_notes ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    361    362    362            �           2604    39618    crm_internal_lead_tags id    DEFAULT     �   ALTER TABLE ONLY public.crm_internal_lead_tags ALTER COLUMN id SET DEFAULT nextval('public.crm_internal_lead_tags_id_seq'::regclass);
 H   ALTER TABLE public.crm_internal_lead_tags ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    364    363    364            �           2604    39644 -   crm_internal_linkedIn_communication_status id    DEFAULT     �   ALTER TABLE ONLY public."crm_internal_linkedIn_communication_status" ALTER COLUMN id SET DEFAULT nextval('public."crm_internal_linkedIn_communication_status_id_seq"'::regclass);
 ^   ALTER TABLE public."crm_internal_linkedIn_communication_status" ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    370    369    370            �           2604    39637 *   crm_internal_phone_communication_status id    DEFAULT     �   ALTER TABLE ONLY public.crm_internal_phone_communication_status ALTER COLUMN id SET DEFAULT nextval('public.crm_internal_phone_communication_status_id_seq'::regclass);
 Y   ALTER TABLE public.crm_internal_phone_communication_status ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    368    367    368            �           2604    39651    crm_internal_user_types id    DEFAULT     �   ALTER TABLE ONLY public.crm_internal_user_types ALTER COLUMN id SET DEFAULT nextval('public.crm_internal_user_types_id_seq'::regclass);
 I   ALTER TABLE public.crm_internal_user_types ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    372    371    372            �           2604    39537    crm_internal_users id    DEFAULT     ~   ALTER TABLE ONLY public.crm_internal_users ALTER COLUMN id SET DEFAULT nextval('public.crm_internal_users_id_seq'::regclass);
 D   ALTER TABLE public.crm_internal_users ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    352    351    352            �           2604    42300    dashboard_search_options id    DEFAULT     �   ALTER TABLE ONLY public.dashboard_search_options ALTER COLUMN id SET DEFAULT nextval('public.dashboard_search_options_id_seq'::regclass);
 J   ALTER TABLE public.dashboard_search_options ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    405    406    406            k           2604    38908    designations id    DEFAULT     r   ALTER TABLE ONLY public.designations ALTER COLUMN id SET DEFAULT nextval('public.designations_id_seq'::regclass);
 >   ALTER TABLE public.designations ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    252    251    252            �           2604    39197    education_details id    DEFAULT     |   ALTER TABLE ONLY public.education_details ALTER COLUMN id SET DEFAULT nextval('public.education_details_id_seq'::regclass);
 C   ALTER TABLE public.education_details ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    300    299    300            �           2604    39183    education_level id    DEFAULT     x   ALTER TABLE ONLY public.education_level ALTER COLUMN id SET DEFAULT nextval('public.education_level_id_seq'::regclass);
 A   ALTER TABLE public.education_level ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    296    295    296            �           2604    42487    email_support_categories id    DEFAULT     �   ALTER TABLE ONLY public.email_support_categories ALTER COLUMN id SET DEFAULT nextval('public.email_support_categories_id_seq'::regclass);
 J   ALTER TABLE public.email_support_categories ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    414    413    414            �           2604    42494    email_supports id    DEFAULT     v   ALTER TABLE ONLY public.email_supports ALTER COLUMN id SET DEFAULT nextval('public.email_supports_id_seq'::regclass);
 @   ALTER TABLE public.email_supports ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    415    416    416            j           2604    38899    event_colors id    DEFAULT     r   ALTER TABLE ONLY public.event_colors ALTER COLUMN id SET DEFAULT nextval('public.event_colors_id_seq'::regclass);
 >   ALTER TABLE public.event_colors ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    249    250    250            �           2604    39370    event_drafts id    DEFAULT     r   ALTER TABLE ONLY public.event_drafts ALTER COLUMN id SET DEFAULT nextval('public.event_drafts_id_seq'::regclass);
 >   ALTER TABLE public.event_drafts ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    320    319    320            �           2604    39463    event_hub_events id    DEFAULT     z   ALTER TABLE ONLY public.event_hub_events ALTER COLUMN id SET DEFAULT nextval('public.event_hub_events_id_seq'::regclass);
 B   ALTER TABLE public.event_hub_events ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    335    336    336            �           2604    39456    event_types id    DEFAULT     q   ALTER TABLE ONLY public.event_types ALTER COLUMN id SET DEFAULT nextval('public.event_types_id_seq1'::regclass);
 =   ALTER TABLE public.event_types ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    333    334    334            �           2604    39027 	   events id    DEFAULT     f   ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);
 8   ALTER TABLE public.events ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    266    265    266            �           2604    39299    experience_details id    DEFAULT     ~   ALTER TABLE ONLY public.experience_details ALTER COLUMN id SET DEFAULT nextval('public.experience_details_id_seq'::regclass);
 D   ALTER TABLE public.experience_details ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    310    309    310            �           2604    42055    faq id    DEFAULT     `   ALTER TABLE ONLY public.faq ALTER COLUMN id SET DEFAULT nextval('public.faq_id_seq'::regclass);
 5   ALTER TABLE public.faq ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    402    401    402            �           2604    39418    features_list id    DEFAULT     t   ALTER TABLE ONLY public.features_list ALTER COLUMN id SET DEFAULT nextval('public.features_list_id_seq'::regclass);
 ?   ALTER TABLE public.features_list ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    330    329    330            �           2604    39190    field_of_studies id    DEFAULT     z   ALTER TABLE ONLY public.field_of_studies ALTER COLUMN id SET DEFAULT nextval('public.field_of_studies_id_seq'::regclass);
 B   ALTER TABLE public.field_of_studies ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    298    297    298            �           2604    39343    general_templates id    DEFAULT     |   ALTER TABLE ONLY public.general_templates ALTER COLUMN id SET DEFAULT nextval('public.general_templates_id_seq'::regclass);
 C   ALTER TABLE public.general_templates ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    313    314    314            �           2604    39334 	   groups id    DEFAULT     f   ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);
 8   ALTER TABLE public.groups ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    311    312    312            �           2604    59939    industries id    DEFAULT     n   ALTER TABLE ONLY public.industries ALTER COLUMN id SET DEFAULT nextval('public.industries_id_seq'::regclass);
 <   ALTER TABLE public.industries ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    433    434    434            �           2604    39153    institution id    DEFAULT     p   ALTER TABLE ONLY public.institution ALTER COLUMN id SET DEFAULT nextval('public.institution_id_seq'::regclass);
 =   ALTER TABLE public.institution ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    288    287    288            m           2604    38922    locations id    DEFAULT     l   ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);
 ;   ALTER TABLE public.locations ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    255    256    256            �           2604    41138    notifications id    DEFAULT     t   ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);
 ?   ALTER TABLE public.notifications ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    396    397    397            �           2604    39075    open_availabilities id    DEFAULT     �   ALTER TABLE ONLY public.open_availabilities ALTER COLUMN id SET DEFAULT nextval('public.open_availabilities_id_seq'::regclass);
 E   ALTER TABLE public.open_availabilities ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    274    273    274            �           2604    39923    open_availability_feedbacks id    DEFAULT     �   ALTER TABLE ONLY public.open_availability_feedbacks ALTER COLUMN id SET DEFAULT nextval('public.open_availability_feedbacks_id_seq'::regclass);
 M   ALTER TABLE public.open_availability_feedbacks ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    388    387    388            �           2604    39911 )   open_availability_questions_change_log id    DEFAULT     �   ALTER TABLE ONLY public.open_availability_questions_change_log ALTER COLUMN id SET DEFAULT nextval('public.open_availability_questions_change_log_id_seq'::regclass);
 X   ALTER TABLE public.open_availability_questions_change_log ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    386    385    386            �           2604    40387 &   open_availability_tag_verifications id    DEFAULT     �   ALTER TABLE ONLY public.open_availability_tag_verifications ALTER COLUMN id SET DEFAULT nextval('public.open_availability_tag_verifications_id_seq'::regclass);
 U   ALTER TABLE public.open_availability_tag_verifications ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    395    394    395            �           2604    39130    open_availability_tags id    DEFAULT     �   ALTER TABLE ONLY public.open_availability_tags ALTER COLUMN id SET DEFAULT nextval('public.open_availability_tags_id_seq'::regclass);
 H   ALTER TABLE public.open_availability_tags ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    284    283    284            �           2604    40319    org_tab_names id    DEFAULT     t   ALTER TABLE ONLY public.org_tab_names ALTER COLUMN id SET DEFAULT nextval('public.org_tab_names_id_seq'::regclass);
 ?   ALTER TABLE public.org_tab_names ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    391    390    391            �           2604    42393    organization_resources id    DEFAULT     �   ALTER TABLE ONLY public.organization_resources ALTER COLUMN id SET DEFAULT nextval('public.organization_resources_id_seq'::regclass);
 H   ALTER TABLE public.organization_resources ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    409    410    410            l           2604    38915    organizations id    DEFAULT     t   ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);
 ?   ALTER TABLE public.organizations ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    254    253    254            �           2604    39053    otps id    DEFAULT     b   ALTER TABLE ONLY public.otps ALTER COLUMN id SET DEFAULT nextval('public.otps_id_seq'::regclass);
 6   ALTER TABLE public.otps ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    270    269    270            �           2604    39099    password_verification_keys id    DEFAULT     �   ALTER TABLE ONLY public.password_verification_keys ALTER COLUMN id SET DEFAULT nextval('public.password_verification_keys_id_seq'::regclass);
 L   ALTER TABLE public.password_verification_keys ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    278    277    278            �           2604    39397    powerbi_reports id    DEFAULT     x   ALTER TABLE ONLY public.powerbi_reports ALTER COLUMN id SET DEFAULT nextval('public.powerbi_reports_id_seq'::regclass);
 A   ALTER TABLE public.powerbi_reports ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    325    326    326            �           2604    39388    predefined_events id    DEFAULT     |   ALTER TABLE ONLY public.predefined_events ALTER COLUMN id SET DEFAULT nextval('public.predefined_events_id_seq'::regclass);
 C   ALTER TABLE public.predefined_events ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    324    323    324            �           2604    39482    predefined_meet_locations id    DEFAULT     �   ALTER TABLE ONLY public.predefined_meet_locations ALTER COLUMN id SET DEFAULT nextval('public.predefined_meet_locations_id_seq'::regclass);
 K   ALTER TABLE public.predefined_meet_locations ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    339    340    340            �           2604    39489    predefined_meet_types id    DEFAULT     �   ALTER TABLE ONLY public.predefined_meet_types ALTER COLUMN id SET DEFAULT nextval('public.predefined_meet_types_id_seq'::regclass);
 G   ALTER TABLE public.predefined_meet_types ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    341    342    342            �           2604    39473    predefined_meets id    DEFAULT     z   ALTER TABLE ONLY public.predefined_meets ALTER COLUMN id SET DEFAULT nextval('public.predefined_meets_id_seq'::regclass);
 B   ALTER TABLE public.predefined_meets ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    338    337    338            �           2604    39514    projects id    DEFAULT     j   ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);
 :   ALTER TABLE public.projects ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    348    347    348            �           2604    43017    propose_new_times id    DEFAULT     |   ALTER TABLE ONLY public.propose_new_times ALTER COLUMN id SET DEFAULT nextval('public.propose_new_times_id_seq'::regclass);
 C   ALTER TABLE public.propose_new_times ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    427    426    427            �           2604    39505    questions id    DEFAULT     l   ALTER TABLE ONLY public.questions ALTER COLUMN id SET DEFAULT nextval('public.questions_id_seq'::regclass);
 ;   ALTER TABLE public.questions ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    345    346    346            �           2604    42386    resources resourceId    DEFAULT     �   ALTER TABLE ONLY public.resources ALTER COLUMN "resourceId" SET DEFAULT nextval('public."resources_resourceId_seq"'::regclass);
 E   ALTER TABLE public.resources ALTER COLUMN "resourceId" DROP DEFAULT;
       public          postgres    false    407    408    408                       2604    39020    secondary_skills id    DEFAULT     z   ALTER TABLE ONLY public.secondary_skills ALTER COLUMN id SET DEFAULT nextval('public.secondary_skills_id_seq'::regclass);
 B   ALTER TABLE public.secondary_skills ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    263    264    264            ~           2604    39013 	   skills id    DEFAULT     f   ALTER TABLE ONLY public.skills ALTER COLUMN id SET DEFAULT nextval('public.skills_id_seq'::regclass);
 8   ALTER TABLE public.skills ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    261    262    262            �           2604    39249 	   states id    DEFAULT     f   ALTER TABLE ONLY public.states ALTER COLUMN id SET DEFAULT nextval('public.states_id_seq'::regclass);
 8   ALTER TABLE public.states ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    301    302    302            �           2604    41950 	   status id    DEFAULT     f   ALTER TABLE ONLY public.status ALTER COLUMN id SET DEFAULT nextval('public.status_id_seq'::regclass);
 8   ALTER TABLE public.status ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    400    399    400            �           2604    42080    subscription_features id    DEFAULT     �   ALTER TABLE ONLY public.subscription_features ALTER COLUMN id SET DEFAULT nextval('public.subscription_features_id_seq'::regclass);
 G   ALTER TABLE public.subscription_features ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    404    403    404            �           2604    39352    subscriptions id    DEFAULT     t   ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);
 ?   ALTER TABLE public.subscriptions ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    315    316    316            �           2604    39437    tab_names id    DEFAULT     l   ALTER TABLE ONLY public.tab_names ALTER COLUMN id SET DEFAULT nextval('public.tab_names_id_seq'::regclass);
 ;   ALTER TABLE public.tab_names ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    331    332    332            �           2604    42549    tabs id    DEFAULT     b   ALTER TABLE ONLY public.tabs ALTER COLUMN id SET DEFAULT nextval('public.tabs_id_seq'::regclass);
 6   ALTER TABLE public.tabs ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    420    419    420            �           2604    42470    tag_link_types id    DEFAULT     v   ALTER TABLE ONLY public.tag_link_types ALTER COLUMN id SET DEFAULT nextval('public.tag_link_types_id_seq'::regclass);
 @   ALTER TABLE public.tag_link_types ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    412    411    412            �           2604    39523    timesheets id    DEFAULT     n   ALTER TABLE ONLY public.timesheets ALTER COLUMN id SET DEFAULT nextval('public.timesheets_id_seq'::regclass);
 <   ALTER TABLE public.timesheets ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    349    350    350            �           2604    68195    timezones id    DEFAULT     l   ALTER TABLE ONLY public.timezones ALTER COLUMN id SET DEFAULT nextval('public.timezones_id_seq'::regclass);
 ;   ALTER TABLE public.timezones ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    435    436    436            �           2604    39123 +   user_associated_general_secondary_skills id    DEFAULT     �   ALTER TABLE ONLY public.user_associated_general_secondary_skills ALTER COLUMN id SET DEFAULT nextval('public.user_associated_general_secondary_skills_id_seq'::regclass);
 Z   ALTER TABLE public.user_associated_general_secondary_skills ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    281    282    282            �           2604    39116 !   user_associated_general_skills id    DEFAULT     �   ALTER TABLE ONLY public.user_associated_general_skills ALTER COLUMN id SET DEFAULT nextval('public.user_associated_general_skills_id_seq'::regclass);
 P   ALTER TABLE public.user_associated_general_skills ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    279    280    280            �           2604    39406    user_current_location id    DEFAULT     �   ALTER TABLE ONLY public.user_current_location ALTER COLUMN id SET DEFAULT nextval('public.user_current_location_id_seq'::regclass);
 G   ALTER TABLE public.user_current_location ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    328    327    328            �           2604    39379    user_defined_email_templates id    DEFAULT     �   ALTER TABLE ONLY public.user_defined_email_templates ALTER COLUMN id SET DEFAULT nextval('public.user_defined_email_templates_id_seq'::regclass);
 N   ALTER TABLE public.user_defined_email_templates ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    321    322    322            �           2604    40337    user_email_signature id    DEFAULT     �   ALTER TABLE ONLY public.user_email_signature ALTER COLUMN id SET DEFAULT nextval('public.user_email_signature_id_seq'::regclass);
 F   ALTER TABLE public.user_email_signature ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    393    392    393            �           2604    39090    user_ips id    DEFAULT     j   ALTER TABLE ONLY public.user_ips ALTER COLUMN id SET DEFAULT nextval('public.user_ips_id_seq'::regclass);
 :   ALTER TABLE public.user_ips ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    276    275    276            �           2604    42873    user_login_logs id    DEFAULT     x   ALTER TABLE ONLY public.user_login_logs ALTER COLUMN id SET DEFAULT nextval('public.user_login_logs_id_seq'::regclass);
 A   ALTER TABLE public.user_login_logs ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    424    425    425            �           2604    39141    user_personality_traits id    DEFAULT     �   ALTER TABLE ONLY public.user_personality_traits ALTER COLUMN id SET DEFAULT nextval('public.user_personality_traits_id_seq'::regclass);
 I   ALTER TABLE public.user_personality_traits ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    285    286    286            �           2604    39176    user_suggested_course id    DEFAULT     �   ALTER TABLE ONLY public.user_suggested_course ALTER COLUMN id SET DEFAULT nextval('public.user_suggested_course_id_seq'::regclass);
 G   ALTER TABLE public.user_suggested_course ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    294    293    294            �           2604    39292    user_suggested_designation id    DEFAULT     �   ALTER TABLE ONLY public.user_suggested_designation ALTER COLUMN id SET DEFAULT nextval('public.user_suggested_designation_id_seq'::regclass);
 L   ALTER TABLE public.user_suggested_designation ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    308    307    308            �           2604    39167    user_suggested_institution id    DEFAULT     �   ALTER TABLE ONLY public.user_suggested_institution ALTER COLUMN id SET DEFAULT nextval('public.user_suggested_institution_id_seq'::regclass);
 L   ALTER TABLE public.user_suggested_institution ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    292    291    292            �           2604    39273    user_suggested_organization id    DEFAULT     �   ALTER TABLE ONLY public.user_suggested_organization ALTER COLUMN id SET DEFAULT nextval('public.user_suggested_organization_id_seq'::regclass);
 M   ALTER TABLE public.user_suggested_organization ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    305    306    306            �           2604    42529    user_tab_activities id    DEFAULT     �   ALTER TABLE ONLY public.user_tab_activities ALTER COLUMN id SET DEFAULT nextval('public.user_tab_activities_id_seq'::regclass);
 E   ALTER TABLE public.user_tab_activities ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    417    418    418            i           2604    38892    user_types id    DEFAULT     n   ALTER TABLE ONLY public.user_types ALTER COLUMN id SET DEFAULT nextval('public.user_types_id_seq'::regclass);
 <   ALTER TABLE public.user_types ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    248    247    248            �           2604    39060    user_verifications id    DEFAULT     ~   ALTER TABLE ONLY public.user_verifications ALTER COLUMN id SET DEFAULT nextval('public.user_verifications_id_seq'::regclass);
 D   ALTER TABLE public.user_verifications ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    271    272    272            n           2604    38938    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    257    258    258            �           2604    39044    zoho_forms id    DEFAULT     n   ALTER TABLE ONLY public.zoho_forms ALTER COLUMN id SET DEFAULT nextval('public.zoho_forms_id_seq'::regclass);
 <   ALTER TABLE public.zoho_forms ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    268    267    268            a          0    51445 
   app_access 
   TABLE DATA           ?   COPY public.app_access ("userId", "applicationId") FROM stdin;
    public          postgres    false    432   j      `          0    51419    applications 
   TABLE DATA           0   COPY public.applications (id, name) FROM stdin;
    public          postgres    false    431         �          0    38994    availabilities 
   TABLE DATA             COPY public.availabilities (id, "tpId", datetime, "candidateId", "interviewStatus", booked, "bookedBy", "formLink", "meetingLink", "isCancelled", "cancelReasonByRecruiter", "recordTime", "recordTimeComments", "isRecordTimeSubmitted", "tpCancellationReason", endtime) FROM stdin;
    public          postgres    false    260   �      -          0    39714    availability_secondary_skills 
   TABLE DATA           ]   COPY public.availability_secondary_skills ("availabilityId", "secondarySkillId") FROM stdin;
    public          postgres    false    377   �      0          0    39759 &   availability_secondary_skills_searched 
   TABLE DATA           f   COPY public.availability_secondary_skills_searched ("availabilityId", "secondarySkillId") FROM stdin;
    public          postgres    false    380   �      ,          0    39699    availability_skills 
   TABLE DATA           J   COPY public.availability_skills ("availabilityId", "skillId") FROM stdin;
    public          postgres    false    376   �      /          0    39744    availability_skills_searched 
   TABLE DATA           S   COPY public.availability_skills_searched ("availabilityId", "skillId") FROM stdin;
    public          postgres    false    379          �          0    39358    ba_organizations 
   TABLE DATA           n   COPY public.ba_organizations (id, "organizationName", "organizationLogo", "isOrgDisabledTagLogo") FROM stdin;
    public          postgres    false    318         _          0    51351 "   blocked_email_by_slot_broadcasters 
   TABLE DATA           b   COPY public.blocked_email_by_slot_broadcasters (id, email, "tagOwnerUserId", "tagId") FROM stdin;
    public          postgres    false    430   w      �          0    39258    cities 
   TABLE DATA           5   COPY public.cities (id, name, "stateId") FROM stdin;
    public          postgres    false    304   �                0    39493    contacts 
   TABLE DATA           c   COPY public.contacts (id, "userId", firstname, lastname, email, phone, title, company) FROM stdin;
    public          postgres    false    344         g          0    76318 	   countries 
   TABLE DATA           -   COPY public.countries (id, name) FROM stdin;
    public          postgres    false    438         �          0    39157    course 
   TABLE DATA           2   COPY public.course (id, "courseName") FROM stdin;
    public          postgres    false    290   F      Y          0    42561    credential_blocked_logs 
   TABLE DATA           L   COPY public.credential_blocked_logs (id, "userId", "createdAt") FROM stdin;
    public          postgres    false    422   c                0    39543 !   crm_internal_communication_status 
   TABLE DATA           G   COPY public.crm_internal_communication_status (id, status) FROM stdin;
    public          postgres    false    354   �      "          0    39627 '   crm_internal_email_communication_status 
   TABLE DATA           M   COPY public.crm_internal_email_communication_status (id, status) FROM stdin;
    public          postgres    false    366   �                0    39589    crm_internal_lead_company_infos 
   TABLE DATA           �   COPY public.crm_internal_lead_company_infos (id, "leadId", "companyName", website, "linkedIn", "companySize", "totalEmployees", "annualRevenue", industry, description) FROM stdin;
    public          postgres    false    360   
                0    39567    crm_internal_lead_contact_infos 
   TABLE DATA           �  COPY public.crm_internal_lead_contact_infos (id, "leadId", email1, "accuracyForEmail1", "communicationStatusForEmail1", "notesForEmail1", email2, "accuracyForEmail2", "communicationStatusForEmail2", "notesForEmail2", phone1, "accuracyForPhone1", "communicationStatusForPhone1", "notesForPhone1", phone2, "accuracyForPhone2", "communicationStatusForPhone2", "notesForPhone2", phone3, "accuracyForPhone3", "communicationStatusForPhone3", "notesForPhone3", phone4, "accuracyForPhone4", "communicationStatusForPhone4", "notesForPhone4", phone5, "accuracyForPhone5", "communicationStatusForPhone5", "notesForPhone5", "linkedIn", "accuracyForLinkedIn", "communicationStatusForLinkedIn", "notesForLinkedIn") FROM stdin;
    public          postgres    false    358   '                0    39550    crm_internal_lead_infos 
   TABLE DATA           I  COPY public.crm_internal_lead_infos (id, firstname, lastname, title, company, email, "accuracyForEmail", "communicationStatusForEmail", "notesForEmail", phone, "accuracyForPhone", "communicationStatusForPhone", "notesForPhone", locality, state, country, "communicationStatus", "viableLead", "createdBy", "createdOn") FROM stdin;
    public          postgres    false    356   D                0    39603    crm_internal_lead_notes 
   TABLE DATA           F   COPY public.crm_internal_lead_notes (id, "leadId", notes) FROM stdin;
    public          postgres    false    362   a                 0    39615    crm_internal_lead_tags 
   TABLE DATA           I   COPY public.crm_internal_lead_tags (id, "leadId", "tagName") FROM stdin;
    public          postgres    false    364   ~      &          0    39641 *   crm_internal_linkedIn_communication_status 
   TABLE DATA           R   COPY public."crm_internal_linkedIn_communication_status" (id, status) FROM stdin;
    public          postgres    false    370   �      $          0    39634 '   crm_internal_phone_communication_status 
   TABLE DATA           M   COPY public.crm_internal_phone_communication_status (id, status) FROM stdin;
    public          postgres    false    368   �      (          0    39648    crm_internal_user_types 
   TABLE DATA           A   COPY public.crm_internal_user_types (id, "userType") FROM stdin;
    public          postgres    false    372   �                0    39534    crm_internal_users 
   TABLE DATA           Y   COPY public.crm_internal_users (id, username, fullname, email, "userTypeId") FROM stdin;
    public          postgres    false    352   �      I          0    42297    dashboard_search_options 
   TABLE DATA           L   COPY public.dashboard_search_options (id, category, name, path) FROM stdin;
    public          postgres    false    406         �          0    38905    designations 
   TABLE DATA           7   COPY public.designations (id, designation) FROM stdin;
    public          postgres    false    252   ,      �          0    39194    education_details 
   TABLE DATA           �   COPY public.education_details (id, "startDate", "endDate", "isCurrentlyPursuing", "userId", "institutionId", "courseId", "userSuggestedInstitutionId", "userSuggestedCourseId", "educationLevelId", "fieldOfStudyId") FROM stdin;
    public          postgres    false    300   I      �          0    39180    education_level 
   TABLE DATA           3   COPY public.education_level (id, name) FROM stdin;
    public          postgres    false    296   f      Q          0    42484    email_support_categories 
   TABLE DATA           <   COPY public.email_support_categories (id, name) FROM stdin;
    public          postgres    false    414   �      S          0    42491    email_supports 
   TABLE DATA           J   COPY public.email_supports (id, "userId", "categoryId", text) FROM stdin;
    public          postgres    false    416   �      �          0    38896    event_colors 
   TABLE DATA           F   COPY public.event_colors (id, color, theme, email_column) FROM stdin;
    public          postgres    false    250   �      �          0    39367    event_drafts 
   TABLE DATA           ~  COPY public.event_drafts (id, "userId", title, "draftName", "requiredGuests", "optionalGuests", date, "startTime", "eventTime", "senderEmail", template, "eventTypeId", recurrence, "recurrenceRepeat", "recurrenceEndDate", "recurrenceCount", "recurrenceNeverEnds", "recurrenceDays", "predefinedMeetId", "isEmailDeleted", "descriptionCheck", "emailCheck", "hideGuestList") FROM stdin;
    public          postgres    false    320   �                0    39460    event_hub_events 
   TABLE DATA           �   COPY public.event_hub_events (id, "userId", "startTime", "endTime", title, "senderEmail", attendees, "meetingLink", "eventId", "eventDurationInMinutes", "eventTypeId", "emailTemplate", "isCancelled", "meetType") FROM stdin;
    public          postgres    false    336   �                0    39453    event_types 
   TABLE DATA           0   COPY public.event_types (id, value) FROM stdin;
    public          postgres    false    334   :�      �          0    39024    events 
   TABLE DATA           V  COPY public.events (id, "userId", "eventId", "startTime", "endTime", sender, title, attendees, "meetingLink", "emailAccount", "seriesMasterId", "updatedAt", "isCancelled", "isDeleted", "activeFlag", "eventColorId", "eventColor", "isReminderSent", "isMicrosoftParentRecurringEvent", "eventIdAcrossAllCalendar", source, "sourceId") FROM stdin;
    public          postgres    false    266   ��      �          0    39296    experience_details 
   TABLE DATA           �   COPY public.experience_details (id, "startDate", "endDate", "isCurrent", "userId", "organizationId", "designationId", "userSuggestedOrganizationId", "userSuggestedDesignationId") FROM stdin;
    public          postgres    false    310   ��      E          0    42052    faq 
   TABLE DATA           9   COPY public.faq (id, question, answer, type) FROM stdin;
    public          postgres    false    402   ��      �          0    39415    features_list 
   TABLE DATA           :   COPY public.features_list (id, "featureName") FROM stdin;
    public          postgres    false    330   S�      �          0    39187    field_of_studies 
   TABLE DATA           4   COPY public.field_of_studies (id, name) FROM stdin;
    public          postgres    false    298   ?�      �          0    39340    general_templates 
   TABLE DATA           ]   COPY public.general_templates (id, name, template, type, "predefinedMeetTypeId") FROM stdin;
    public          postgres    false    314   \�      9          0    39953    group_members 
   TABLE DATA           ?   COPY public.group_members ("contactId", "groupId") FROM stdin;
    public          postgres    false    389   �      �          0    39331    groups 
   TABLE DATA           g   COPY public.groups (id, name, "createdBy", "createdAt", description, "adminName", "addMe") FROM stdin;
    public          postgres    false    312   ��      c          0    59936 
   industries 
   TABLE DATA           .   COPY public.industries (id, name) FROM stdin;
    public          postgres    false    434   [�      �          0    39150    institution 
   TABLE DATA           <   COPY public.institution (id, "institutionName") FROM stdin;
    public          postgres    false    288   ��      �          0    38919 	   locations 
   TABLE DATA           1   COPY public.locations (id, location) FROM stdin;
    public          postgres    false    256   �      A          0    41135    notifications 
   TABLE DATA           �   COPY public.notifications (id, "userId", description, datetime, "createdAt", type, "isRead", "meetingLink", creator, "eventId", title, source, "openAvailabilityId", "emailAccount", "eventIdAcrossAllCalendar") FROM stdin;
    public          postgres    false    397   2�      �          0    39072    open_availabilities 
   TABLE DATA           �  COPY public.open_availabilities (id, "userId", datetime, booked, "receiverEmail", "receiverName", "receiverPhone", "eventType", "senderEmail", "emailServiceProvider", "meetingLink", "tagId", "eventId", status, "statusId", comments, "tagTypeId", endtime, "meetingPurpose", "isCancelled", "meetType", "guestTimezone", "houseNo", "houseName", street, area, state, city, pincode, landmark, "mapLink", "isBookedSlotUpdated", "isAcceptedByOwner", "bookedAt", "isEmailReminderSent", "rescheduleReason") FROM stdin;
    public          postgres    false    274   �      8          0    39920    open_availability_feedbacks 
   TABLE DATA           g   COPY public.open_availability_feedbacks (id, "openAvailabilityId", question, answer, type) FROM stdin;
    public          postgres    false    388   `      4          0    39834    open_availability_questions 
   TABLE DATA           f   COPY public.open_availability_questions ("openAvailabilityTagId", "questionId", required) FROM stdin;
    public          postgres    false    384   b      6          0    39908 &   open_availability_questions_change_log 
   TABLE DATA           x   COPY public.open_availability_questions_change_log (id, "openAvailabilityTagId", "questionId", "addedTime") FROM stdin;
    public          postgres    false    386   Ib      ?          0    40384 #   open_availability_tag_verifications 
   TABLE DATA           z   COPY public.open_availability_tag_verifications (id, "userId", "tagId", datetime, count, email, "parsedDate") FROM stdin;
    public          postgres    false    395   1j      �          0    39127    open_availability_tags 
   TABLE DATA           �  COPY public.open_availability_tags (id, "userId", "tagName", "defaultEmail", "isDeleted", "openAvailabilityText", template, "eventDuration", "eventTypeId", "isAllowedToAddAttendees", "isEmailDeleted", image, title, "showCommentBox", "isPrimaryEmailTag", "meetType", "emailVisibility", "houseNo", "houseName", street, area, state, city, pincode, landmark, "mapLink", country) FROM stdin;
    public          postgres    false    284   �~      ;          0    40316    org_tab_names 
   TABLE DATA           P   COPY public.org_tab_names (id, "tabId", "orgId", "tabNameOrgGiven") FROM stdin;
    public          postgres    false    391   E�      M          0    42390    organization_resources 
   TABLE DATA           e   COPY public.organization_resources (id, "orgId", "apiKey", "resourceId", "orgSecretKey") FROM stdin;
    public          postgres    false    410   م      �          0    38912    organizations 
   TABLE DATA           9   COPY public.organizations (id, organization) FROM stdin;
    public          postgres    false    254   ��      �          0    39050    otps 
   TABLE DATA           .   COPY public.otps (id, email, otp) FROM stdin;
    public          postgres    false    270   �      �          0    39096    password_verification_keys 
   TABLE DATA           ]   COPY public.password_verification_keys (id, "userId", "passwordVerificationKey") FROM stdin;
    public          postgres    false    278   R�      �          0    39394    powerbi_reports 
   TABLE DATA           S   COPY public.powerbi_reports (id, "reportId", "userTypeId", parameters) FROM stdin;
    public          postgres    false    326   ކ      �          0    39385    predefined_events 
   TABLE DATA           �   COPY public.predefined_events (id, "userId", title, "requiredGuests", "optionalGuests", "startTime", "eventTime", "senderEmail", template, "eventTypeId", "groupId", count, "predefinedMeetId", "isEmailDeleted") FROM stdin;
    public          postgres    false    324   ��                0    39479    predefined_meet_locations 
   TABLE DATA           >   COPY public.predefined_meet_locations (id, value) FROM stdin;
    public          postgres    false    340   �      
          0    39486    predefined_meet_types 
   TABLE DATA           :   COPY public.predefined_meet_types (id, value) FROM stdin;
    public          postgres    false    342   �                0    39470    predefined_meets 
   TABLE DATA           n   COPY public.predefined_meets (id, "userId", title, type, location, url, address, phone, passcode) FROM stdin;
    public          postgres    false    338   X�                0    39511    projects 
   TABLE DATA           g   COPY public.projects (id, "userId", "projectName", "startDate", "endDate", "defaultHours") FROM stdin;
    public          postgres    false    348   �      ]          0    43014    propose_new_times 
   TABLE DATA           �   COPY public.propose_new_times (id, "eventId", email, "startTime", "endTime", comment, "isRejected", "userId", "eventIdAcrossAllCalendar") FROM stdin;
    public          postgres    false    427   �                0    39502 	   questions 
   TABLE DATA           n   COPY public.questions (id, question, "userId", type, option1, option2, option3, option4, option5) FROM stdin;
    public          postgres    false    346   �      K          0    42383 	   resources 
   TABLE DATA           A   COPY public.resources ("resourceId", "resourceName") FROM stdin;
    public          postgres    false    408   (�      �          0    39017    secondary_skills 
   TABLE DATA           D   COPY public.secondary_skills (id, "secondarySkillName") FROM stdin;
    public          postgres    false    264   E�      )          0    39654    skill_secondary_skills 
   TABLE DATA           O   COPY public.skill_secondary_skills ("skillId", "secondarySkillId") FROM stdin;
    public          postgres    false    373   b�      .          0    39729    skill_zoho_forms 
   TABLE DATA           C   COPY public.skill_zoho_forms ("skillId", "zohoFormId") FROM stdin;
    public          postgres    false    378   �      �          0    39010    skills 
   TABLE DATA           1   COPY public.skills (id, "skillName") FROM stdin;
    public          postgres    false    262   ��      �          0    39246    states 
   TABLE DATA           7   COPY public.states (id, name, "countryId") FROM stdin;
    public          postgres    false    302         C          0    41947    status 
   TABLE DATA           ,   COPY public.status (id, status) FROM stdin;
    public          postgres    false    400   �      G          0    42077    subscription_features 
   TABLE DATA           `   COPY public.subscription_features (id, "featureId", "subscriptionId", availability) FROM stdin;
    public          postgres    false    404   3�      �          0    39349    subscriptions 
   TABLE DATA           a   COPY public.subscriptions (id, type, price, "monthlyPriceId", "yearlyPriceId", text) FROM stdin;
    public          postgres    false    316   Z�                 0    39434 	   tab_names 
   TABLE DATA           @   COPY public.tab_names (id, "userTypeId", "tabName") FROM stdin;
    public          postgres    false    332   :�      W          0    42546    tabs 
   TABLE DATA           J   COPY public.tabs (id, "tabNumbering", "tabName", description) FROM stdin;
    public          postgres    false    420   D�      O          0    42467    tag_link_types 
   TABLE DATA           <   COPY public.tag_link_types (id, "typeId", name) FROM stdin;
    public          postgres    false    412   =�      3          0    39819    tag_members 
   TABLE DATA           H   COPY public.tag_members ("openAvailabilityTagId", "userId") FROM stdin;
    public          postgres    false    383   ٘                0    39520 
   timesheets 
   TABLE DATA           ~   COPY public.timesheets (id, "userId", "projectId", "weekStartDate", "weekEndDate", "totalHours", status, remarks) FROM stdin;
    public          postgres    false    350   ��      e          0    68192 	   timezones 
   TABLE DATA           F   COPY public.timezones (id, timezone, value, abbreviation) FROM stdin;
    public          postgres    false    436   �      +          0    39684    tp_secondary_skills 
   TABLE DATA           K   COPY public.tp_secondary_skills ("userId", "secondarySkillId") FROM stdin;
    public          postgres    false    375   ��      *          0    39669 	   tp_skills 
   TABLE DATA           8   COPY public.tp_skills ("userId", "skillId") FROM stdin;
    public          postgres    false    374   ��      �          0    39120 (   user_associated_general_secondary_skills 
   TABLE DATA           f   COPY public.user_associated_general_secondary_skills (id, "secondarySkillName", "userId") FROM stdin;
    public          postgres    false    282   Κ      �          0    39113    user_associated_general_skills 
   TABLE DATA           S   COPY public.user_associated_general_skills (id, "skillName", "userId") FROM stdin;
    public          postgres    false    280   �      �          0    39403    user_current_location 
   TABLE DATA           [   COPY public.user_current_location (id, "userId", "currentCityId", "addedTime") FROM stdin;
    public          postgres    false    328   �      �          0    39376    user_defined_email_templates 
   TABLE DATA           r   COPY public.user_defined_email_templates (id, "userId", name, template, type, "predefinedMeetTypeId") FROM stdin;
    public          postgres    false    322   X�      =          0    40334    user_email_signature 
   TABLE DATA           u   COPY public.user_email_signature (id, "userId", title, fullname, phonenumber, "organizationId", website) FROM stdin;
    public          postgres    false    393   h�      2          0    39789    user_general_secondary_skills 
   TABLE DATA           U   COPY public.user_general_secondary_skills ("userId", "secondarySkillId") FROM stdin;
    public          postgres    false    382   ��      1          0    39774    user_general_skills 
   TABLE DATA           B   COPY public.user_general_skills ("userId", "skillId") FROM stdin;
    public          postgres    false    381   ɞ      �          0    39087    user_ips 
   TABLE DATA           P   COPY public.user_ips (id, "userId", ip, "loggedTime", "ipLocation") FROM stdin;
    public          postgres    false    276   �      [          0    42870    user_login_logs 
   TABLE DATA           �   COPY public.user_login_logs (id, "userId", "createdAt", "isCredentialsDisabled", "credentialDisabledTimeStamp", "credentialEnabledTimeStamp", "lastLoginTried") FROM stdin;
    public          postgres    false    425   ̲      �          0    39138    user_personality_traits 
   TABLE DATA           �   COPY public.user_personality_traits (id, "userId", collaboration, communication, "criticalThinking", resilience, empathy) FROM stdin;
    public          postgres    false    286   ��      �          0    39173    user_suggested_course 
   TABLE DATA           i   COPY public.user_suggested_course (id, course, "userId", "educationLevelId", "fieldOfStudy") FROM stdin;
    public          postgres    false    294   ��      �          0    39289    user_suggested_designation 
   TABLE DATA           O   COPY public.user_suggested_designation (id, designation, "userId") FROM stdin;
    public          postgres    false    308   ��      �          0    39164    user_suggested_institution 
   TABLE DATA           �   COPY public.user_suggested_institution (id, "institutionName", "userId", website, "cityId", "stateId", "countryId") FROM stdin;
    public          postgres    false    292   	�      �          0    39270    user_suggested_organization 
   TABLE DATA           �   COPY public.user_suggested_organization (id, "organizationName", "userId", website, "linkedinUrl", "cityId", "stateId", "countryId") FROM stdin;
    public          postgres    false    306   &�      U          0    42526    user_tab_activities 
   TABLE DATA           \   COPY public.user_tab_activities (id, "userId", "tabId", "startTime", "endTime") FROM stdin;
    public          postgres    false    418   C�      �          0    38889 
   user_types 
   TABLE DATA           4   COPY public.user_types (id, "userType") FROM stdin;
    public          postgres    false    248   �	      �          0    39057    user_verifications 
   TABLE DATA           j   COPY public.user_verifications (id, "userId", email, "isAccountVerified", "accountVerifyKey") FROM stdin;
    public          postgres    false    272   	      �          0    38935    users 
   TABLE DATA           "  COPY public.users (id, username, fullname, email, "emailServiceProvider", email2, "email2ServiceProvider", email3, "email3ServiceProvider", "userTypeId", password, "isPasswordUpdated", "isDeleted", "emailAccessToken", "emailRefreshToken", "email2AccessToken", "email2RefreshToken", "email3AccessToken", "email3RefreshToken", "passwordUpdatedCount", "temporaryPassword", "eventColorForEmail", "eventColorForEmail2", "eventColorForEmail3", "profilePicture", "nextSyncTokenForEmail", "nextSyncTokenForEmail2", "nextSyncTokenForEmail3", "lastPasswordUpdatedForSecurity", "designationId", "organizationId", "locationId", "timezoneId", phonenumber, phonenumber2, phonenumber3, phonenumber4, phonenumber5, "primaryPhonenumber", "phonenumberCountryCode", "phonenumber2CountryCode", "phonenumber3CountryCode", "phonenumber4CountryCode", "phonenumber5CountryCode", theme, "aboutMeText", "isNotificationDisabled", "subscriptionId", "baOrgId", "stripeCustomerId", "stripeSubscriptionId", "usernameUpdatedCount", "googleResourceIdEmail1", "googleChannelIdEmail1", "googleWatchExpirationEmail1", "googleResourceIdEmail2", "googleChannelIdEmail2", "googleWatchExpirationEmail2", "googleResourceIdEmail3", "googleChannelIdEmail3", "googleWatchExpirationEmail3", "microsoftSubscriptionIdEmail1", "microsoftSubscriptionExpirationEmail1", "microsoftSubscriptionIdEmail2", "microsoftSubscriptionExpirationEmail2", "microsoftSubscriptionIdEmail3", "microsoftSubscriptionExpirationEmail3", "createdAt", "lastLoginTimeStamp", "freeSubscriptionExpiration", "isFreeTrialOver", "mfaSecret", "mfaEnabled", "mfaConfigured", "mfaManditory", "isCredentialsDisabled", "emailSyncTimeStamp", "email2SyncTimeStamp", "email3SyncTimeStamp", "credentialDisabledTimeStamp", "credentialEnabledTimeStamp", "subscriptionUpgradeTimeStamp", "subscriptionDowngradeTimeStamp", "emailSyncExpiration", "email2SyncExpiration", "email3SyncExpiration", "firstTimeEmailSyncTimeStamp", "firstTimeEmail2SyncTimeStamp", "firstTimeEmail3SyncTimeStamp", "isUsernameUpdated", business, industry, "isMergeCalendarGuideChecked") FROM stdin;
    public          postgres    false    258   u	      �          0    39041 
   zoho_forms 
   TABLE DATA           :   COPY public.zoho_forms (id, "formName", link) FROM stdin;
    public          postgres    false    268   �F	      �           0    0    availabilities_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.availabilities_id_seq', 5, true);
          public          postgres    false    259            �           0    0    ba_organizations_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.ba_organizations_id_seq', 1, false);
          public          postgres    false    317            �           0    0 )   blocked_email_by_slot_broadcasters_id_seq    SEQUENCE SET     X   SELECT pg_catalog.setval('public.blocked_email_by_slot_broadcasters_id_seq', 15, true);
          public          postgres    false    429            �           0    0    cities_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.cities_id_seq', 4, true);
          public          postgres    false    303            �           0    0    contacts_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.contacts_id_seq', 228, true);
          public          postgres    false    343            �           0    0    countries_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.countries_id_seq', 2, true);
          public          postgres    false    437            �           0    0    course_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.course_id_seq', 1, false);
          public          postgres    false    289            �           0    0    credential_blocked_logs_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.credential_blocked_logs_id_seq', 6, true);
          public          postgres    false    421            �           0    0 (   crm_internal_communication_status_id_seq    SEQUENCE SET     W   SELECT pg_catalog.setval('public.crm_internal_communication_status_id_seq', 1, false);
          public          postgres    false    353            �           0    0 .   crm_internal_email_communication_status_id_seq    SEQUENCE SET     ]   SELECT pg_catalog.setval('public.crm_internal_email_communication_status_id_seq', 1, false);
          public          postgres    false    365            �           0    0 &   crm_internal_lead_company_infos_id_seq    SEQUENCE SET     U   SELECT pg_catalog.setval('public.crm_internal_lead_company_infos_id_seq', 1, false);
          public          postgres    false    359            �           0    0 &   crm_internal_lead_contact_infos_id_seq    SEQUENCE SET     U   SELECT pg_catalog.setval('public.crm_internal_lead_contact_infos_id_seq', 1, false);
          public          postgres    false    357            �           0    0    crm_internal_lead_infos_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.crm_internal_lead_infos_id_seq', 1, false);
          public          postgres    false    355            �           0    0    crm_internal_lead_notes_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.crm_internal_lead_notes_id_seq', 1, false);
          public          postgres    false    361            �           0    0    crm_internal_lead_tags_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.crm_internal_lead_tags_id_seq', 1, false);
          public          postgres    false    363            �           0    0 1   crm_internal_linkedIn_communication_status_id_seq    SEQUENCE SET     b   SELECT pg_catalog.setval('public."crm_internal_linkedIn_communication_status_id_seq"', 1, false);
          public          postgres    false    369            �           0    0 .   crm_internal_phone_communication_status_id_seq    SEQUENCE SET     ]   SELECT pg_catalog.setval('public.crm_internal_phone_communication_status_id_seq', 1, false);
          public          postgres    false    367            �           0    0    crm_internal_user_types_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.crm_internal_user_types_id_seq', 1, false);
          public          postgres    false    371            �           0    0    crm_internal_users_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.crm_internal_users_id_seq', 1, false);
          public          postgres    false    351            �           0    0    dashboard_search_options_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.dashboard_search_options_id_seq', 1, false);
          public          postgres    false    405            �           0    0    designations_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.designations_id_seq', 1, false);
          public          postgres    false    251            �           0    0    education_details_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.education_details_id_seq', 1, false);
          public          postgres    false    299            �           0    0    education_level_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.education_level_id_seq', 1, false);
          public          postgres    false    295            �           0    0    email_support_categories_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.email_support_categories_id_seq', 2, true);
          public          postgres    false    413            �           0    0    email_supports_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.email_supports_id_seq', 10, true);
          public          postgres    false    415            �           0    0    event_colors_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.event_colors_id_seq', 1, false);
          public          postgres    false    249            �           0    0    event_drafts_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.event_drafts_id_seq', 12, true);
          public          postgres    false    319            �           0    0    event_hub_events_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.event_hub_events_id_seq', 451, true);
          public          postgres    false    335            �           0    0    event_types_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.event_types_id_seq', 4, true);
          public          postgres    false    246            �           0    0    event_types_id_seq1    SEQUENCE SET     B   SELECT pg_catalog.setval('public.event_types_id_seq1', 1, false);
          public          postgres    false    333            �           0    0    events_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.events_id_seq', 63547, true);
          public          postgres    false    265            �           0    0    experience_details_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.experience_details_id_seq', 1, false);
          public          postgres    false    309            �           0    0 
   faq_id_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('public.faq_id_seq', 18, true);
          public          postgres    false    401            �           0    0    features_list_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.features_list_id_seq', 1, false);
          public          postgres    false    329            �           0    0    field_of_studies_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.field_of_studies_id_seq', 1, false);
          public          postgres    false    297            �           0    0    general_templates_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.general_templates_id_seq', 1, false);
          public          postgres    false    313            �           0    0    groups_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.groups_id_seq', 57, true);
          public          postgres    false    311            �           0    0    industries_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.industries_id_seq', 10, true);
          public          postgres    false    433            �           0    0    institution_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.institution_id_seq', 1, false);
          public          postgres    false    287            �           0    0    locations_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.locations_id_seq', 1, false);
          public          postgres    false    255            �           0    0    notifications_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.notifications_id_seq', 1439, true);
          public          postgres    false    396            �           0    0    open_availabilities_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.open_availabilities_id_seq', 5567, true);
          public          postgres    false    273            �           0    0 "   open_availability_feedbacks_id_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('public.open_availability_feedbacks_id_seq', 299, true);
          public          postgres    false    387            �           0    0 -   open_availability_questions_change_log_id_seq    SEQUENCE SET     ]   SELECT pg_catalog.setval('public.open_availability_questions_change_log_id_seq', 230, true);
          public          postgres    false    385            �           0    0 *   open_availability_tag_verifications_id_seq    SEQUENCE SET     Z   SELECT pg_catalog.setval('public.open_availability_tag_verifications_id_seq', 397, true);
          public          postgres    false    394            �           0    0    open_availability_tags_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.open_availability_tags_id_seq', 81, true);
          public          postgres    false    283            �           0    0    org_tab_names_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.org_tab_names_id_seq', 4, true);
          public          postgres    false    390            �           0    0    organization_resources_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.organization_resources_id_seq', 1, false);
          public          postgres    false    409            �           0    0    organizations_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.organizations_id_seq', 1, true);
          public          postgres    false    253            �           0    0    otps_id_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('public.otps_id_seq', 6, true);
          public          postgres    false    269            �           0    0 !   password_verification_keys_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.password_verification_keys_id_seq', 4, true);
          public          postgres    false    277            �           0    0    power_bi_reports_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.power_bi_reports_seq', 1, false);
          public          postgres    false    245            �           0    0    powerbi_reports_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.powerbi_reports_id_seq', 1, false);
          public          postgres    false    325            �           0    0    predefined_events_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.predefined_events_id_seq', 24, true);
          public          postgres    false    323            �           0    0     predefined_meet_locations_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.predefined_meet_locations_id_seq', 3, true);
          public          postgres    false    339            �           0    0    predefined_meet_types_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.predefined_meet_types_id_seq', 3, true);
          public          postgres    false    341            �           0    0    predefined_meets_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.predefined_meets_id_seq', 8, true);
          public          postgres    false    337            �           0    0    projects_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.projects_id_seq', 1, false);
          public          postgres    false    347            �           0    0    propose_new_times_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.propose_new_times_id_seq', 38, true);
          public          postgres    false    426                        0    0    questions_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.questions_id_seq', 79, true);
          public          postgres    false    345                       0    0    resources_resourceId_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public."resources_resourceId_seq"', 1, false);
          public          postgres    false    407                       0    0    secondary_skills_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.secondary_skills_id_seq', 1, false);
          public          postgres    false    263                       0    0    skills_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.skills_id_seq', 1, true);
          public          postgres    false    261                       0    0    states_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.states_id_seq', 4, true);
          public          postgres    false    301                       0    0    status_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.status_id_seq', 1, false);
          public          postgres    false    399                       0    0    subscription_features_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.subscription_features_id_seq', 1, false);
          public          postgres    false    403                       0    0    subscriptions_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.subscriptions_id_seq', 1, false);
          public          postgres    false    315                       0    0    tab_names_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.tab_names_id_seq', 5, true);
          public          postgres    false    331            	           0    0    tabs_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.tabs_id_seq', 1, false);
          public          postgres    false    419            
           0    0    tag_link_types_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.tag_link_types_id_seq', 4, true);
          public          postgres    false    411                       0    0    timesheets_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.timesheets_id_seq', 1, false);
          public          postgres    false    349                       0    0    timezones_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.timezones_id_seq', 25, true);
          public          postgres    false    435                       0    0 /   user_associated_general_secondary_skills_id_seq    SEQUENCE SET     ]   SELECT pg_catalog.setval('public.user_associated_general_secondary_skills_id_seq', 2, true);
          public          postgres    false    281                       0    0 %   user_associated_general_skills_id_seq    SEQUENCE SET     T   SELECT pg_catalog.setval('public.user_associated_general_skills_id_seq', 18, true);
          public          postgres    false    279                       0    0    user_current_location_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.user_current_location_id_seq', 133, true);
          public          postgres    false    327                       0    0 #   user_defined_email_templates_id_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('public.user_defined_email_templates_id_seq', 28, true);
          public          postgres    false    321                       0    0    user_email_signature_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.user_email_signature_id_seq', 1, true);
          public          postgres    false    392                       0    0    user_ips_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.user_ips_id_seq', 462, true);
          public          postgres    false    275                       0    0    user_login_logs_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.user_login_logs_id_seq', 497, true);
          public          postgres    false    424                       0    0    user_personality_traits_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.user_personality_traits_id_seq', 1, true);
          public          postgres    false    285                       0    0    user_suggested_course_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.user_suggested_course_id_seq', 1, false);
          public          postgres    false    293                       0    0 !   user_suggested_designation_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public.user_suggested_designation_id_seq', 1, false);
          public          postgres    false    307                       0    0 !   user_suggested_institution_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public.user_suggested_institution_id_seq', 1, false);
          public          postgres    false    291                       0    0 "   user_suggested_organization_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public.user_suggested_organization_id_seq', 1, false);
          public          postgres    false    305                       0    0    user_tab_activities_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.user_tab_activities_id_seq', 1604, true);
          public          postgres    false    417                       0    0    user_types_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.user_types_id_seq', 5, true);
          public          postgres    false    247                       0    0    user_verifications_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.user_verifications_id_seq', 115, true);
          public          postgres    false    271                       0    0    users_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.users_id_seq', 72, true);
          public          postgres    false    257                       0    0    zoho_forms_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.zoho_forms_id_seq', 1, false);
          public          postgres    false    267            �           2606    51449    app_access app_access_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.app_access
    ADD CONSTRAINT app_access_pkey PRIMARY KEY ("userId", "applicationId");
 D   ALTER TABLE ONLY public.app_access DROP CONSTRAINT app_access_pkey;
       public            postgres    false    432    432            �           2606    51425    applications applications_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.applications DROP CONSTRAINT applications_pkey;
       public            postgres    false    431                       2606    39003 "   availabilities availabilities_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.availabilities
    ADD CONSTRAINT availabilities_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.availabilities DROP CONSTRAINT availabilities_pkey;
       public            postgres    false    260            �           2606    39718 @   availability_secondary_skills availability_secondary_skills_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.availability_secondary_skills
    ADD CONSTRAINT availability_secondary_skills_pkey PRIMARY KEY ("availabilityId", "secondarySkillId");
 j   ALTER TABLE ONLY public.availability_secondary_skills DROP CONSTRAINT availability_secondary_skills_pkey;
       public            postgres    false    377    377            �           2606    39763 R   availability_secondary_skills_searched availability_secondary_skills_searched_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.availability_secondary_skills_searched
    ADD CONSTRAINT availability_secondary_skills_searched_pkey PRIMARY KEY ("availabilityId", "secondarySkillId");
 |   ALTER TABLE ONLY public.availability_secondary_skills_searched DROP CONSTRAINT availability_secondary_skills_searched_pkey;
       public            postgres    false    380    380            �           2606    39703 ,   availability_skills availability_skills_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.availability_skills
    ADD CONSTRAINT availability_skills_pkey PRIMARY KEY ("availabilityId", "skillId");
 V   ALTER TABLE ONLY public.availability_skills DROP CONSTRAINT availability_skills_pkey;
       public            postgres    false    376    376            �           2606    39748 >   availability_skills_searched availability_skills_searched_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.availability_skills_searched
    ADD CONSTRAINT availability_skills_searched_pkey PRIMARY KEY ("availabilityId", "skillId");
 h   ALTER TABLE ONLY public.availability_skills_searched DROP CONSTRAINT availability_skills_searched_pkey;
       public            postgres    false    379    379            E           2606    39365 &   ba_organizations ba_organizations_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.ba_organizations
    ADD CONSTRAINT ba_organizations_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.ba_organizations DROP CONSTRAINT ba_organizations_pkey;
       public            postgres    false    318            �           2606    51356 J   blocked_email_by_slot_broadcasters blocked_email_by_slot_broadcasters_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.blocked_email_by_slot_broadcasters
    ADD CONSTRAINT blocked_email_by_slot_broadcasters_pkey PRIMARY KEY (id);
 t   ALTER TABLE ONLY public.blocked_email_by_slot_broadcasters DROP CONSTRAINT blocked_email_by_slot_broadcasters_pkey;
       public            postgres    false    430            7           2606    39263    cities cities_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.cities DROP CONSTRAINT cities_pkey;
       public            postgres    false    304            _           2606    39500    contacts contacts_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.contacts DROP CONSTRAINT contacts_pkey;
       public            postgres    false    344            �           2606    76323    countries countries_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.countries DROP CONSTRAINT countries_pkey;
       public            postgres    false    438            )           2606    39162    course course_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.course DROP CONSTRAINT course_pkey;
       public            postgres    false    290            �           2606    42566 4   credential_blocked_logs credential_blocked_logs_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.credential_blocked_logs
    ADD CONSTRAINT credential_blocked_logs_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.credential_blocked_logs DROP CONSTRAINT credential_blocked_logs_pkey;
       public            postgres    false    422            i           2606    39548 H   crm_internal_communication_status crm_internal_communication_status_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.crm_internal_communication_status
    ADD CONSTRAINT crm_internal_communication_status_pkey PRIMARY KEY (id);
 r   ALTER TABLE ONLY public.crm_internal_communication_status DROP CONSTRAINT crm_internal_communication_status_pkey;
       public            postgres    false    354            u           2606    39632 T   crm_internal_email_communication_status crm_internal_email_communication_status_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.crm_internal_email_communication_status
    ADD CONSTRAINT crm_internal_email_communication_status_pkey PRIMARY KEY (id);
 ~   ALTER TABLE ONLY public.crm_internal_email_communication_status DROP CONSTRAINT crm_internal_email_communication_status_pkey;
       public            postgres    false    366            o           2606    39596 D   crm_internal_lead_company_infos crm_internal_lead_company_infos_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.crm_internal_lead_company_infos
    ADD CONSTRAINT crm_internal_lead_company_infos_pkey PRIMARY KEY (id);
 n   ALTER TABLE ONLY public.crm_internal_lead_company_infos DROP CONSTRAINT crm_internal_lead_company_infos_pkey;
       public            postgres    false    360            m           2606    39582 D   crm_internal_lead_contact_infos crm_internal_lead_contact_infos_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.crm_internal_lead_contact_infos
    ADD CONSTRAINT crm_internal_lead_contact_infos_pkey PRIMARY KEY (id);
 n   ALTER TABLE ONLY public.crm_internal_lead_contact_infos DROP CONSTRAINT crm_internal_lead_contact_infos_pkey;
       public            postgres    false    358            k           2606    39560 4   crm_internal_lead_infos crm_internal_lead_infos_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.crm_internal_lead_infos
    ADD CONSTRAINT crm_internal_lead_infos_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.crm_internal_lead_infos DROP CONSTRAINT crm_internal_lead_infos_pkey;
       public            postgres    false    356            q           2606    39608 4   crm_internal_lead_notes crm_internal_lead_notes_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.crm_internal_lead_notes
    ADD CONSTRAINT crm_internal_lead_notes_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.crm_internal_lead_notes DROP CONSTRAINT crm_internal_lead_notes_pkey;
       public            postgres    false    362            s           2606    39620 2   crm_internal_lead_tags crm_internal_lead_tags_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.crm_internal_lead_tags
    ADD CONSTRAINT crm_internal_lead_tags_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.crm_internal_lead_tags DROP CONSTRAINT crm_internal_lead_tags_pkey;
       public            postgres    false    364            y           2606    39646 Z   crm_internal_linkedIn_communication_status crm_internal_linkedIn_communication_status_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public."crm_internal_linkedIn_communication_status"
    ADD CONSTRAINT "crm_internal_linkedIn_communication_status_pkey" PRIMARY KEY (id);
 �   ALTER TABLE ONLY public."crm_internal_linkedIn_communication_status" DROP CONSTRAINT "crm_internal_linkedIn_communication_status_pkey";
       public            postgres    false    370            w           2606    39639 T   crm_internal_phone_communication_status crm_internal_phone_communication_status_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.crm_internal_phone_communication_status
    ADD CONSTRAINT crm_internal_phone_communication_status_pkey PRIMARY KEY (id);
 ~   ALTER TABLE ONLY public.crm_internal_phone_communication_status DROP CONSTRAINT crm_internal_phone_communication_status_pkey;
       public            postgres    false    368            {           2606    39653 4   crm_internal_user_types crm_internal_user_types_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.crm_internal_user_types
    ADD CONSTRAINT crm_internal_user_types_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.crm_internal_user_types DROP CONSTRAINT crm_internal_user_types_pkey;
       public            postgres    false    372            g           2606    39541 *   crm_internal_users crm_internal_users_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.crm_internal_users
    ADD CONSTRAINT crm_internal_users_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.crm_internal_users DROP CONSTRAINT crm_internal_users_pkey;
       public            postgres    false    352            �           2606    42304 6   dashboard_search_options dashboard_search_options_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.dashboard_search_options
    ADD CONSTRAINT dashboard_search_options_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.dashboard_search_options DROP CONSTRAINT dashboard_search_options_pkey;
       public            postgres    false    406            �           2606    38910    designations designations_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.designations
    ADD CONSTRAINT designations_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.designations DROP CONSTRAINT designations_pkey;
       public            postgres    false    252            3           2606    39202 (   education_details education_details_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.education_details
    ADD CONSTRAINT education_details_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.education_details DROP CONSTRAINT education_details_pkey;
       public            postgres    false    300            /           2606    39185 $   education_level education_level_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.education_level
    ADD CONSTRAINT education_level_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.education_level DROP CONSTRAINT education_level_pkey;
       public            postgres    false    296            �           2606    42489 6   email_support_categories email_support_categories_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.email_support_categories
    ADD CONSTRAINT email_support_categories_pkey PRIMARY KEY (id);
 `   ALTER TABLE ONLY public.email_support_categories DROP CONSTRAINT email_support_categories_pkey;
       public            postgres    false    414            �           2606    42496 "   email_supports email_supports_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.email_supports
    ADD CONSTRAINT email_supports_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.email_supports DROP CONSTRAINT email_supports_pkey;
       public            postgres    false    416            �           2606    38903    event_colors event_colors_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.event_colors
    ADD CONSTRAINT event_colors_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.event_colors DROP CONSTRAINT event_colors_pkey;
       public            postgres    false    250            G           2606    39374    event_drafts event_drafts_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.event_drafts
    ADD CONSTRAINT event_drafts_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.event_drafts DROP CONSTRAINT event_drafts_pkey;
       public            postgres    false    320            W           2606    39468 &   event_hub_events event_hub_events_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.event_hub_events
    ADD CONSTRAINT event_hub_events_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.event_hub_events DROP CONSTRAINT event_hub_events_pkey;
       public            postgres    false    336            U           2606    39458    event_types event_types_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.event_types
    ADD CONSTRAINT event_types_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.event_types DROP CONSTRAINT event_types_pkey;
       public            postgres    false    334                       2606    39034    events events_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.events DROP CONSTRAINT events_pkey;
       public            postgres    false    266            =           2606    39304 *   experience_details experience_details_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.experience_details
    ADD CONSTRAINT experience_details_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.experience_details DROP CONSTRAINT experience_details_pkey;
       public            postgres    false    310            �           2606    42059    faq faq_pkey 
   CONSTRAINT     J   ALTER TABLE ONLY public.faq
    ADD CONSTRAINT faq_pkey PRIMARY KEY (id);
 6   ALTER TABLE ONLY public.faq DROP CONSTRAINT faq_pkey;
       public            postgres    false    402            Q           2606    39420     features_list features_list_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.features_list
    ADD CONSTRAINT features_list_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.features_list DROP CONSTRAINT features_list_pkey;
       public            postgres    false    330            1           2606    39192 &   field_of_studies field_of_studies_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.field_of_studies
    ADD CONSTRAINT field_of_studies_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.field_of_studies DROP CONSTRAINT field_of_studies_pkey;
       public            postgres    false    298            A           2606    39347 (   general_templates general_templates_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.general_templates
    ADD CONSTRAINT general_templates_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.general_templates DROP CONSTRAINT general_templates_pkey;
       public            postgres    false    314            �           2606    39957     group_members group_members_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_pkey PRIMARY KEY ("contactId", "groupId");
 J   ALTER TABLE ONLY public.group_members DROP CONSTRAINT group_members_pkey;
       public            postgres    false    389    389            ?           2606    39338    groups groups_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.groups DROP CONSTRAINT groups_pkey;
       public            postgres    false    312            �           2606    59941    industries industries_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.industries
    ADD CONSTRAINT industries_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.industries DROP CONSTRAINT industries_pkey;
       public            postgres    false    434            '           2606    39155    institution institution_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.institution
    ADD CONSTRAINT institution_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.institution DROP CONSTRAINT institution_pkey;
       public            postgres    false    288                       2606    38924    locations locations_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.locations DROP CONSTRAINT locations_pkey;
       public            postgres    false    256            �           2606    41144     notifications notifications_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.notifications DROP CONSTRAINT notifications_pkey;
       public            postgres    false    397                       2606    39080 ,   open_availabilities open_availabilities_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.open_availabilities
    ADD CONSTRAINT open_availabilities_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.open_availabilities DROP CONSTRAINT open_availabilities_pkey;
       public            postgres    false    274            �           2606    39927 <   open_availability_feedbacks open_availability_feedbacks_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.open_availability_feedbacks
    ADD CONSTRAINT open_availability_feedbacks_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.open_availability_feedbacks DROP CONSTRAINT open_availability_feedbacks_pkey;
       public            postgres    false    388            �           2606    39916 R   open_availability_questions_change_log open_availability_questions_change_log_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.open_availability_questions_change_log
    ADD CONSTRAINT open_availability_questions_change_log_pkey PRIMARY KEY (id);
 |   ALTER TABLE ONLY public.open_availability_questions_change_log DROP CONSTRAINT open_availability_questions_change_log_pkey;
       public            postgres    false    386            �           2606    40370 <   open_availability_questions open_availability_questions_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.open_availability_questions
    ADD CONSTRAINT open_availability_questions_pkey PRIMARY KEY ("openAvailabilityTagId", "questionId");
 f   ALTER TABLE ONLY public.open_availability_questions DROP CONSTRAINT open_availability_questions_pkey;
       public            postgres    false    384    384            �           2606    40389 L   open_availability_tag_verifications open_availability_tag_verifications_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.open_availability_tag_verifications
    ADD CONSTRAINT open_availability_tag_verifications_pkey PRIMARY KEY (id);
 v   ALTER TABLE ONLY public.open_availability_tag_verifications DROP CONSTRAINT open_availability_tag_verifications_pkey;
       public            postgres    false    395            #           2606    39136 2   open_availability_tags open_availability_tags_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.open_availability_tags
    ADD CONSTRAINT open_availability_tags_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.open_availability_tags DROP CONSTRAINT open_availability_tags_pkey;
       public            postgres    false    284            �           2606    40321     org_tab_names org_tab_names_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.org_tab_names
    ADD CONSTRAINT org_tab_names_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.org_tab_names DROP CONSTRAINT org_tab_names_pkey;
       public            postgres    false    391            �           2606    42433 8   organization_resources organization_resources_apiKey_key 
   CONSTRAINT     y   ALTER TABLE ONLY public.organization_resources
    ADD CONSTRAINT "organization_resources_apiKey_key" UNIQUE ("apiKey");
 d   ALTER TABLE ONLY public.organization_resources DROP CONSTRAINT "organization_resources_apiKey_key";
       public            postgres    false    410            �           2606    42431 9   organization_resources organization_resources_apiKey_key1 
   CONSTRAINT     z   ALTER TABLE ONLY public.organization_resources
    ADD CONSTRAINT "organization_resources_apiKey_key1" UNIQUE ("apiKey");
 e   ALTER TABLE ONLY public.organization_resources DROP CONSTRAINT "organization_resources_apiKey_key1";
       public            postgres    false    410            �           2606    42419 7   organization_resources organization_resources_orgId_key 
   CONSTRAINT     w   ALTER TABLE ONLY public.organization_resources
    ADD CONSTRAINT "organization_resources_orgId_key" UNIQUE ("orgId");
 c   ALTER TABLE ONLY public.organization_resources DROP CONSTRAINT "organization_resources_orgId_key";
       public            postgres    false    410            �           2606    42397 2   organization_resources organization_resources_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.organization_resources
    ADD CONSTRAINT organization_resources_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.organization_resources DROP CONSTRAINT organization_resources_pkey;
       public            postgres    false    410                       2606    38917     organizations organizations_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.organizations DROP CONSTRAINT organizations_pkey;
       public            postgres    false    254                       2606    39055    otps otps_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.otps
    ADD CONSTRAINT otps_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.otps DROP CONSTRAINT otps_pkey;
       public            postgres    false    270                       2606    39101 :   password_verification_keys password_verification_keys_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.password_verification_keys
    ADD CONSTRAINT password_verification_keys_pkey PRIMARY KEY (id);
 d   ALTER TABLE ONLY public.password_verification_keys DROP CONSTRAINT password_verification_keys_pkey;
       public            postgres    false    278            M           2606    39401 $   powerbi_reports powerbi_reports_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.powerbi_reports
    ADD CONSTRAINT powerbi_reports_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.powerbi_reports DROP CONSTRAINT powerbi_reports_pkey;
       public            postgres    false    326            K           2606    39392 (   predefined_events predefined_events_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.predefined_events
    ADD CONSTRAINT predefined_events_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.predefined_events DROP CONSTRAINT predefined_events_pkey;
       public            postgres    false    324            [           2606    39484 8   predefined_meet_locations predefined_meet_locations_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.predefined_meet_locations
    ADD CONSTRAINT predefined_meet_locations_pkey PRIMARY KEY (id);
 b   ALTER TABLE ONLY public.predefined_meet_locations DROP CONSTRAINT predefined_meet_locations_pkey;
       public            postgres    false    340            ]           2606    39491 0   predefined_meet_types predefined_meet_types_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.predefined_meet_types
    ADD CONSTRAINT predefined_meet_types_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.predefined_meet_types DROP CONSTRAINT predefined_meet_types_pkey;
       public            postgres    false    342            Y           2606    39477 &   predefined_meets predefined_meets_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.predefined_meets
    ADD CONSTRAINT predefined_meets_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.predefined_meets DROP CONSTRAINT predefined_meets_pkey;
       public            postgres    false    338            c           2606    39518    projects projects_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.projects DROP CONSTRAINT projects_pkey;
       public            postgres    false    348            �           2606    43021 (   propose_new_times propose_new_times_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.propose_new_times
    ADD CONSTRAINT propose_new_times_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.propose_new_times DROP CONSTRAINT propose_new_times_pkey;
       public            postgres    false    427            a           2606    39509    questions questions_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.questions DROP CONSTRAINT questions_pkey;
       public            postgres    false    346            �           2606    42388    resources resources_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY ("resourceId");
 B   ALTER TABLE ONLY public.resources DROP CONSTRAINT resources_pkey;
       public            postgres    false    408                       2606    39022 &   secondary_skills secondary_skills_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.secondary_skills
    ADD CONSTRAINT secondary_skills_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.secondary_skills DROP CONSTRAINT secondary_skills_pkey;
       public            postgres    false    264            }           2606    39658 2   skill_secondary_skills skill_secondary_skills_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.skill_secondary_skills
    ADD CONSTRAINT skill_secondary_skills_pkey PRIMARY KEY ("skillId", "secondarySkillId");
 \   ALTER TABLE ONLY public.skill_secondary_skills DROP CONSTRAINT skill_secondary_skills_pkey;
       public            postgres    false    373    373            �           2606    39733 &   skill_zoho_forms skill_zoho_forms_pkey 
   CONSTRAINT     y   ALTER TABLE ONLY public.skill_zoho_forms
    ADD CONSTRAINT skill_zoho_forms_pkey PRIMARY KEY ("skillId", "zohoFormId");
 P   ALTER TABLE ONLY public.skill_zoho_forms DROP CONSTRAINT skill_zoho_forms_pkey;
       public            postgres    false    378    378                       2606    39015    skills skills_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.skills DROP CONSTRAINT skills_pkey;
       public            postgres    false    262            5           2606    39251    states states_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.states DROP CONSTRAINT states_pkey;
       public            postgres    false    302            �           2606    41952    status status_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.status DROP CONSTRAINT status_pkey;
       public            postgres    false    400            �           2606    42082 0   subscription_features subscription_features_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.subscription_features
    ADD CONSTRAINT subscription_features_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.subscription_features DROP CONSTRAINT subscription_features_pkey;
       public            postgres    false    404            C           2606    39356     subscriptions subscriptions_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.subscriptions DROP CONSTRAINT subscriptions_pkey;
       public            postgres    false    316            S           2606    39439    tab_names tab_names_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.tab_names
    ADD CONSTRAINT tab_names_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.tab_names DROP CONSTRAINT tab_names_pkey;
       public            postgres    false    332            �           2606    42553    tabs tabs_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.tabs
    ADD CONSTRAINT tabs_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.tabs DROP CONSTRAINT tabs_pkey;
       public            postgres    false    420            �           2606    42555    tabs tabs_tabNumbering_key 
   CONSTRAINT     a   ALTER TABLE ONLY public.tabs
    ADD CONSTRAINT "tabs_tabNumbering_key" UNIQUE ("tabNumbering");
 F   ALTER TABLE ONLY public.tabs DROP CONSTRAINT "tabs_tabNumbering_key";
       public            postgres    false    420            �           2606    42474 "   tag_link_types tag_link_types_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.tag_link_types
    ADD CONSTRAINT tag_link_types_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.tag_link_types DROP CONSTRAINT tag_link_types_pkey;
       public            postgres    false    412            �           2606    39823    tag_members tag_members_pkey 
   CONSTRAINT     y   ALTER TABLE ONLY public.tag_members
    ADD CONSTRAINT tag_members_pkey PRIMARY KEY ("openAvailabilityTagId", "userId");
 F   ALTER TABLE ONLY public.tag_members DROP CONSTRAINT tag_members_pkey;
       public            postgres    false    383    383            e           2606    39527    timesheets timesheets_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.timesheets
    ADD CONSTRAINT timesheets_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.timesheets DROP CONSTRAINT timesheets_pkey;
       public            postgres    false    350            �           2606    68199    timezones timezones_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.timezones
    ADD CONSTRAINT timezones_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.timezones DROP CONSTRAINT timezones_pkey;
       public            postgres    false    436            �           2606    39688 ,   tp_secondary_skills tp_secondary_skills_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.tp_secondary_skills
    ADD CONSTRAINT tp_secondary_skills_pkey PRIMARY KEY ("userId", "secondarySkillId");
 V   ALTER TABLE ONLY public.tp_secondary_skills DROP CONSTRAINT tp_secondary_skills_pkey;
       public            postgres    false    375    375                       2606    39673    tp_skills tp_skills_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.tp_skills
    ADD CONSTRAINT tp_skills_pkey PRIMARY KEY ("userId", "skillId");
 B   ALTER TABLE ONLY public.tp_skills DROP CONSTRAINT tp_skills_pkey;
       public            postgres    false    374    374            !           2606    39125 V   user_associated_general_secondary_skills user_associated_general_secondary_skills_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.user_associated_general_secondary_skills
    ADD CONSTRAINT user_associated_general_secondary_skills_pkey PRIMARY KEY (id);
 �   ALTER TABLE ONLY public.user_associated_general_secondary_skills DROP CONSTRAINT user_associated_general_secondary_skills_pkey;
       public            postgres    false    282                       2606    39118 B   user_associated_general_skills user_associated_general_skills_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.user_associated_general_skills
    ADD CONSTRAINT user_associated_general_skills_pkey PRIMARY KEY (id);
 l   ALTER TABLE ONLY public.user_associated_general_skills DROP CONSTRAINT user_associated_general_skills_pkey;
       public            postgres    false    280            O           2606    39408 0   user_current_location user_current_location_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.user_current_location
    ADD CONSTRAINT user_current_location_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.user_current_location DROP CONSTRAINT user_current_location_pkey;
       public            postgres    false    328            I           2606    39383 >   user_defined_email_templates user_defined_email_templates_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.user_defined_email_templates
    ADD CONSTRAINT user_defined_email_templates_pkey PRIMARY KEY (id);
 h   ALTER TABLE ONLY public.user_defined_email_templates DROP CONSTRAINT user_defined_email_templates_pkey;
       public            postgres    false    322            �           2606    40341 .   user_email_signature user_email_signature_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.user_email_signature
    ADD CONSTRAINT user_email_signature_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.user_email_signature DROP CONSTRAINT user_email_signature_pkey;
       public            postgres    false    393            �           2606    39793 @   user_general_secondary_skills user_general_secondary_skills_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.user_general_secondary_skills
    ADD CONSTRAINT user_general_secondary_skills_pkey PRIMARY KEY ("userId", "secondarySkillId");
 j   ALTER TABLE ONLY public.user_general_secondary_skills DROP CONSTRAINT user_general_secondary_skills_pkey;
       public            postgres    false    382    382            �           2606    39778 ,   user_general_skills user_general_skills_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY public.user_general_skills
    ADD CONSTRAINT user_general_skills_pkey PRIMARY KEY ("userId", "skillId");
 V   ALTER TABLE ONLY public.user_general_skills DROP CONSTRAINT user_general_skills_pkey;
       public            postgres    false    381    381                       2606    39094    user_ips user_ips_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.user_ips
    ADD CONSTRAINT user_ips_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.user_ips DROP CONSTRAINT user_ips_pkey;
       public            postgres    false    276            �           2606    42875 $   user_login_logs user_login_logs_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.user_login_logs
    ADD CONSTRAINT user_login_logs_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.user_login_logs DROP CONSTRAINT user_login_logs_pkey;
       public            postgres    false    425            %           2606    39143 4   user_personality_traits user_personality_traits_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.user_personality_traits
    ADD CONSTRAINT user_personality_traits_pkey PRIMARY KEY (id);
 ^   ALTER TABLE ONLY public.user_personality_traits DROP CONSTRAINT user_personality_traits_pkey;
       public            postgres    false    286            -           2606    39178 0   user_suggested_course user_suggested_course_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.user_suggested_course
    ADD CONSTRAINT user_suggested_course_pkey PRIMARY KEY (id);
 Z   ALTER TABLE ONLY public.user_suggested_course DROP CONSTRAINT user_suggested_course_pkey;
       public            postgres    false    294            ;           2606    39294 :   user_suggested_designation user_suggested_designation_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.user_suggested_designation
    ADD CONSTRAINT user_suggested_designation_pkey PRIMARY KEY (id);
 d   ALTER TABLE ONLY public.user_suggested_designation DROP CONSTRAINT user_suggested_designation_pkey;
       public            postgres    false    308            +           2606    39171 :   user_suggested_institution user_suggested_institution_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.user_suggested_institution
    ADD CONSTRAINT user_suggested_institution_pkey PRIMARY KEY (id);
 d   ALTER TABLE ONLY public.user_suggested_institution DROP CONSTRAINT user_suggested_institution_pkey;
       public            postgres    false    292            9           2606    39277 <   user_suggested_organization user_suggested_organization_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY public.user_suggested_organization
    ADD CONSTRAINT user_suggested_organization_pkey PRIMARY KEY (id);
 f   ALTER TABLE ONLY public.user_suggested_organization DROP CONSTRAINT user_suggested_organization_pkey;
       public            postgres    false    306            �           2606    42533 ,   user_tab_activities user_tab_activities_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.user_tab_activities
    ADD CONSTRAINT user_tab_activities_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.user_tab_activities DROP CONSTRAINT user_tab_activities_pkey;
       public            postgres    false    418            �           2606    38894    user_types user_types_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.user_types
    ADD CONSTRAINT user_types_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.user_types DROP CONSTRAINT user_types_pkey;
       public            postgres    false    248                       2606    39065 *   user_verifications user_verifications_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.user_verifications
    ADD CONSTRAINT user_verifications_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.user_verifications DROP CONSTRAINT user_verifications_pkey;
       public            postgres    false    272                       2606    41608    users users_email_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
 ?   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key;
       public            postgres    false    258                       2606    38948    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public            postgres    false    258            	           2606    76427    users users_username_key 
   CONSTRAINT     W   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_username_key;
       public            postgres    false    258                       2606    39048    zoho_forms zoho_forms_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.zoho_forms
    ADD CONSTRAINT zoho_forms_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.zoho_forms DROP CONSTRAINT zoho_forms_pkey;
       public            postgres    false    268                       2620    39901 )   events after_insert_event_set_active_flag    TRIGGER     �   CREATE TRIGGER after_insert_event_set_active_flag AFTER INSERT ON public.events FOR EACH ROW EXECUTE FUNCTION public.set_active_flag();
 B   DROP TRIGGER after_insert_event_set_active_flag ON public.events;
       public          postgres    false    266    440                       2620    39918 D   open_availability_questions after_insert_open_availability_questions    TRIGGER     �   CREATE TRIGGER after_insert_open_availability_questions AFTER INSERT ON public.open_availability_questions FOR EACH ROW EXECUTE FUNCTION public.log_open_availability_questions();
 ]   DROP TRIGGER after_insert_open_availability_questions ON public.open_availability_questions;
       public          postgres    false    441    384                       2606    51455 (   app_access app_access_applicationId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.app_access
    ADD CONSTRAINT "app_access_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES public.applications(id) ON UPDATE CASCADE ON DELETE CASCADE;
 T   ALTER TABLE ONLY public.app_access DROP CONSTRAINT "app_access_applicationId_fkey";
       public          postgres    false    5577    431    432                       2606    51450 !   app_access app_access_userId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.app_access
    ADD CONSTRAINT "app_access_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 M   ALTER TABLE ONLY public.app_access DROP CONSTRAINT "app_access_userId_fkey";
       public          postgres    false    432    5383    258            �           2606    51384 '   availabilities availabilities_tpId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.availabilities
    ADD CONSTRAINT "availabilities_tpId_fkey" FOREIGN KEY ("tpId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 S   ALTER TABLE ONLY public.availabilities DROP CONSTRAINT "availabilities_tpId_fkey";
       public          postgres    false    260    5383    258            �           2606    39719 O   availability_secondary_skills availability_secondary_skills_availabilityId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.availability_secondary_skills
    ADD CONSTRAINT "availability_secondary_skills_availabilityId_fkey" FOREIGN KEY ("availabilityId") REFERENCES public.availabilities(id) ON UPDATE CASCADE ON DELETE CASCADE;
 {   ALTER TABLE ONLY public.availability_secondary_skills DROP CONSTRAINT "availability_secondary_skills_availabilityId_fkey";
       public          postgres    false    5387    377    260                       2606    39764 a   availability_secondary_skills_searched availability_secondary_skills_searched_availabilityId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.availability_secondary_skills_searched
    ADD CONSTRAINT "availability_secondary_skills_searched_availabilityId_fkey" FOREIGN KEY ("availabilityId") REFERENCES public.availabilities(id) ON UPDATE CASCADE ON DELETE CASCADE;
 �   ALTER TABLE ONLY public.availability_secondary_skills_searched DROP CONSTRAINT "availability_secondary_skills_searched_availabilityId_fkey";
       public          postgres    false    5387    260    380                       2606    39769 c   availability_secondary_skills_searched availability_secondary_skills_searched_secondarySkillId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.availability_secondary_skills_searched
    ADD CONSTRAINT "availability_secondary_skills_searched_secondarySkillId_fkey" FOREIGN KEY ("secondarySkillId") REFERENCES public.secondary_skills(id) ON UPDATE CASCADE ON DELETE CASCADE;
 �   ALTER TABLE ONLY public.availability_secondary_skills_searched DROP CONSTRAINT "availability_secondary_skills_searched_secondarySkillId_fkey";
       public          postgres    false    264    380    5391            �           2606    39724 Q   availability_secondary_skills availability_secondary_skills_secondarySkillId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.availability_secondary_skills
    ADD CONSTRAINT "availability_secondary_skills_secondarySkillId_fkey" FOREIGN KEY ("secondarySkillId") REFERENCES public.secondary_skills(id) ON UPDATE CASCADE ON DELETE CASCADE;
 }   ALTER TABLE ONLY public.availability_secondary_skills DROP CONSTRAINT "availability_secondary_skills_secondarySkillId_fkey";
       public          postgres    false    5391    264    377            �           2606    39704 ;   availability_skills availability_skills_availabilityId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.availability_skills
    ADD CONSTRAINT "availability_skills_availabilityId_fkey" FOREIGN KEY ("availabilityId") REFERENCES public.availabilities(id) ON UPDATE CASCADE ON DELETE CASCADE;
 g   ALTER TABLE ONLY public.availability_skills DROP CONSTRAINT "availability_skills_availabilityId_fkey";
       public          postgres    false    260    5387    376                       2606    39749 M   availability_skills_searched availability_skills_searched_availabilityId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.availability_skills_searched
    ADD CONSTRAINT "availability_skills_searched_availabilityId_fkey" FOREIGN KEY ("availabilityId") REFERENCES public.availabilities(id) ON UPDATE CASCADE ON DELETE CASCADE;
 y   ALTER TABLE ONLY public.availability_skills_searched DROP CONSTRAINT "availability_skills_searched_availabilityId_fkey";
       public          postgres    false    5387    260    379                       2606    39754 F   availability_skills_searched availability_skills_searched_skillId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.availability_skills_searched
    ADD CONSTRAINT "availability_skills_searched_skillId_fkey" FOREIGN KEY ("skillId") REFERENCES public.skills(id) ON UPDATE CASCADE ON DELETE CASCADE;
 r   ALTER TABLE ONLY public.availability_skills_searched DROP CONSTRAINT "availability_skills_searched_skillId_fkey";
       public          postgres    false    379    262    5389            �           2606    39709 4   availability_skills availability_skills_skillId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.availability_skills
    ADD CONSTRAINT "availability_skills_skillId_fkey" FOREIGN KEY ("skillId") REFERENCES public.skills(id) ON UPDATE CASCADE ON DELETE CASCADE;
 `   ALTER TABLE ONLY public.availability_skills DROP CONSTRAINT "availability_skills_skillId_fkey";
       public          postgres    false    376    262    5389            �           2606    41752    cities cities_stateId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cities
    ADD CONSTRAINT "cities_stateId_fkey" FOREIGN KEY ("stateId") REFERENCES public.states(id) ON UPDATE CASCADE;
 F   ALTER TABLE ONLY public.cities DROP CONSTRAINT "cities_stateId_fkey";
       public          postgres    false    5429    302    304            �           2606    41876 K   crm_internal_lead_company_infos crm_internal_lead_company_infos_leadId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.crm_internal_lead_company_infos
    ADD CONSTRAINT "crm_internal_lead_company_infos_leadId_fkey" FOREIGN KEY ("leadId") REFERENCES public.crm_internal_lead_infos(id) ON UPDATE CASCADE ON DELETE CASCADE;
 w   ALTER TABLE ONLY public.crm_internal_lead_company_infos DROP CONSTRAINT "crm_internal_lead_company_infos_leadId_fkey";
       public          postgres    false    360    356    5483            �           2606    41855 K   crm_internal_lead_contact_infos crm_internal_lead_contact_infos_leadId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.crm_internal_lead_contact_infos
    ADD CONSTRAINT "crm_internal_lead_contact_infos_leadId_fkey" FOREIGN KEY ("leadId") REFERENCES public.crm_internal_lead_infos(id) ON UPDATE CASCADE ON DELETE CASCADE;
 w   ALTER TABLE ONLY public.crm_internal_lead_contact_infos DROP CONSTRAINT "crm_internal_lead_contact_infos_leadId_fkey";
       public          postgres    false    358    356    5483            �           2606    41848 H   crm_internal_lead_infos crm_internal_lead_infos_communicationStatus_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.crm_internal_lead_infos
    ADD CONSTRAINT "crm_internal_lead_infos_communicationStatus_fkey" FOREIGN KEY ("communicationStatus") REFERENCES public.crm_internal_communication_status(id) ON UPDATE CASCADE ON DELETE CASCADE;
 t   ALTER TABLE ONLY public.crm_internal_lead_infos DROP CONSTRAINT "crm_internal_lead_infos_communicationStatus_fkey";
       public          postgres    false    354    5481    356            �           2606    41881 ;   crm_internal_lead_notes crm_internal_lead_notes_leadId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.crm_internal_lead_notes
    ADD CONSTRAINT "crm_internal_lead_notes_leadId_fkey" FOREIGN KEY ("leadId") REFERENCES public.crm_internal_lead_infos(id) ON UPDATE CASCADE ON DELETE CASCADE;
 g   ALTER TABLE ONLY public.crm_internal_lead_notes DROP CONSTRAINT "crm_internal_lead_notes_leadId_fkey";
       public          postgres    false    356    362    5483            �           2606    41886 9   crm_internal_lead_tags crm_internal_lead_tags_leadId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.crm_internal_lead_tags
    ADD CONSTRAINT "crm_internal_lead_tags_leadId_fkey" FOREIGN KEY ("leadId") REFERENCES public.crm_internal_lead_infos(id) ON UPDATE CASCADE ON DELETE CASCADE;
 e   ALTER TABLE ONLY public.crm_internal_lead_tags DROP CONSTRAINT "crm_internal_lead_tags_leadId_fkey";
       public          postgres    false    364    5483    356            �           2606    41722 1   education_details education_details_courseId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.education_details
    ADD CONSTRAINT "education_details_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES public.course(id) ON UPDATE CASCADE;
 ]   ALTER TABLE ONLY public.education_details DROP CONSTRAINT "education_details_courseId_fkey";
       public          postgres    false    5417    300    290            �           2606    41737 9   education_details education_details_educationLevelId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.education_details
    ADD CONSTRAINT "education_details_educationLevelId_fkey" FOREIGN KEY ("educationLevelId") REFERENCES public.education_level(id) ON UPDATE CASCADE;
 e   ALTER TABLE ONLY public.education_details DROP CONSTRAINT "education_details_educationLevelId_fkey";
       public          postgres    false    5423    300    296            �           2606    41742 7   education_details education_details_fieldOfStudyId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.education_details
    ADD CONSTRAINT "education_details_fieldOfStudyId_fkey" FOREIGN KEY ("fieldOfStudyId") REFERENCES public.field_of_studies(id) ON UPDATE CASCADE;
 c   ALTER TABLE ONLY public.education_details DROP CONSTRAINT "education_details_fieldOfStudyId_fkey";
       public          postgres    false    5425    300    298            �           2606    41717 6   education_details education_details_institutionId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.education_details
    ADD CONSTRAINT "education_details_institutionId_fkey" FOREIGN KEY ("institutionId") REFERENCES public.institution(id) ON UPDATE CASCADE;
 b   ALTER TABLE ONLY public.education_details DROP CONSTRAINT "education_details_institutionId_fkey";
       public          postgres    false    5415    288    300            �           2606    41712 /   education_details education_details_userId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.education_details
    ADD CONSTRAINT "education_details_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 [   ALTER TABLE ONLY public.education_details DROP CONSTRAINT "education_details_userId_fkey";
       public          postgres    false    5383    258    300            �           2606    41732 >   education_details education_details_userSuggestedCourseId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.education_details
    ADD CONSTRAINT "education_details_userSuggestedCourseId_fkey" FOREIGN KEY ("userSuggestedCourseId") REFERENCES public.user_suggested_course(id) ON UPDATE CASCADE;
 j   ALTER TABLE ONLY public.education_details DROP CONSTRAINT "education_details_userSuggestedCourseId_fkey";
       public          postgres    false    294    300    5421            �           2606    41727 C   education_details education_details_userSuggestedInstitutionId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.education_details
    ADD CONSTRAINT "education_details_userSuggestedInstitutionId_fkey" FOREIGN KEY ("userSuggestedInstitutionId") REFERENCES public.user_suggested_institution(id) ON UPDATE CASCADE;
 o   ALTER TABLE ONLY public.education_details DROP CONSTRAINT "education_details_userSuggestedInstitutionId_fkey";
       public          postgres    false    292    5419    300            �           2606    42022 /   event_drafts event_drafts_predefinedMeetId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.event_drafts
    ADD CONSTRAINT "event_drafts_predefinedMeetId_fkey" FOREIGN KEY ("predefinedMeetId") REFERENCES public.predefined_meets(id) ON UPDATE CASCADE;
 [   ALTER TABLE ONLY public.event_drafts DROP CONSTRAINT "event_drafts_predefinedMeetId_fkey";
       public          postgres    false    320    338    5465            �           2606    51687    events events_userId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.events
    ADD CONSTRAINT "events_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 E   ALTER TABLE ONLY public.events DROP CONSTRAINT "events_userId_fkey";
       public          postgres    false    5383    266    258            �           2606    41779 8   experience_details experience_details_designationId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.experience_details
    ADD CONSTRAINT "experience_details_designationId_fkey" FOREIGN KEY ("designationId") REFERENCES public.designations(id) ON UPDATE CASCADE;
 d   ALTER TABLE ONLY public.experience_details DROP CONSTRAINT "experience_details_designationId_fkey";
       public          postgres    false    252    310    5375            �           2606    41774 9   experience_details experience_details_organizationId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.experience_details
    ADD CONSTRAINT "experience_details_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public.organizations(id) ON UPDATE CASCADE;
 e   ALTER TABLE ONLY public.experience_details DROP CONSTRAINT "experience_details_organizationId_fkey";
       public          postgres    false    5377    254    310            �           2606    41769 1   experience_details experience_details_userId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.experience_details
    ADD CONSTRAINT "experience_details_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ]   ALTER TABLE ONLY public.experience_details DROP CONSTRAINT "experience_details_userId_fkey";
       public          postgres    false    310    258    5383            �           2606    41789 E   experience_details experience_details_userSuggestedDesignationId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.experience_details
    ADD CONSTRAINT "experience_details_userSuggestedDesignationId_fkey" FOREIGN KEY ("userSuggestedDesignationId") REFERENCES public.user_suggested_designation(id) ON UPDATE CASCADE;
 q   ALTER TABLE ONLY public.experience_details DROP CONSTRAINT "experience_details_userSuggestedDesignationId_fkey";
       public          postgres    false    308    5435    310            �           2606    41784 F   experience_details experience_details_userSuggestedOrganizationId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.experience_details
    ADD CONSTRAINT "experience_details_userSuggestedOrganizationId_fkey" FOREIGN KEY ("userSuggestedOrganizationId") REFERENCES public.user_suggested_organization(id) ON UPDATE CASCADE;
 r   ALTER TABLE ONLY public.experience_details DROP CONSTRAINT "experience_details_userSuggestedOrganizationId_fkey";
       public          postgres    false    310    306    5433            �           2606    76442 3   open_availabilities open_availabilities_userId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.open_availabilities
    ADD CONSTRAINT "open_availabilities_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.open_availabilities DROP CONSTRAINT "open_availabilities_userId_fkey";
       public          postgres    false    274    258    5383                       2606    52021 O   open_availability_feedbacks open_availability_feedbacks_openAvailabilityId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.open_availability_feedbacks
    ADD CONSTRAINT "open_availability_feedbacks_openAvailabilityId_fkey" FOREIGN KEY ("openAvailabilityId") REFERENCES public.open_availabilities(id) ON UPDATE CASCADE ON DELETE CASCADE;
 {   ALTER TABLE ONLY public.open_availability_feedbacks DROP CONSTRAINT "open_availability_feedbacks_openAvailabilityId_fkey";
       public          postgres    false    388    274    5401                       2606    40364 R   open_availability_questions open_availability_questions_openAvailabilityTagId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.open_availability_questions
    ADD CONSTRAINT "open_availability_questions_openAvailabilityTagId_fkey" FOREIGN KEY ("openAvailabilityTagId") REFERENCES public.open_availability_tags(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ~   ALTER TABLE ONLY public.open_availability_questions DROP CONSTRAINT "open_availability_questions_openAvailabilityTagId_fkey";
       public          postgres    false    284    5411    384                       2606    40371 G   open_availability_questions open_availability_questions_questionId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.open_availability_questions
    ADD CONSTRAINT "open_availability_questions_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public.questions(id) ON UPDATE CASCADE ON DELETE CASCADE;
 s   ALTER TABLE ONLY public.open_availability_questions DROP CONSTRAINT "open_availability_questions_questionId_fkey";
       public          postgres    false    346    384    5473                       2606    41825 &   org_tab_names org_tab_names_tabId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.org_tab_names
    ADD CONSTRAINT "org_tab_names_tabId_fkey" FOREIGN KEY ("tabId") REFERENCES public.tab_names(id) ON UPDATE CASCADE ON DELETE CASCADE;
 R   ALTER TABLE ONLY public.org_tab_names DROP CONSTRAINT "org_tab_names_tabId_fkey";
       public          postgres    false    332    391    5459            �           2606    41808 9   predefined_events predefined_events_predefinedMeetId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.predefined_events
    ADD CONSTRAINT "predefined_events_predefinedMeetId_fkey" FOREIGN KEY ("predefinedMeetId") REFERENCES public.predefined_meets(id) ON UPDATE CASCADE;
 e   ALTER TABLE ONLY public.predefined_events DROP CONSTRAINT "predefined_events_predefinedMeetId_fkey";
       public          postgres    false    324    338    5465            �           2606    39664 C   skill_secondary_skills skill_secondary_skills_secondarySkillId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.skill_secondary_skills
    ADD CONSTRAINT "skill_secondary_skills_secondarySkillId_fkey" FOREIGN KEY ("secondarySkillId") REFERENCES public.secondary_skills(id) ON UPDATE CASCADE ON DELETE CASCADE;
 o   ALTER TABLE ONLY public.skill_secondary_skills DROP CONSTRAINT "skill_secondary_skills_secondarySkillId_fkey";
       public          postgres    false    373    264    5391            �           2606    39659 :   skill_secondary_skills skill_secondary_skills_skillId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.skill_secondary_skills
    ADD CONSTRAINT "skill_secondary_skills_skillId_fkey" FOREIGN KEY ("skillId") REFERENCES public.skills(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.skill_secondary_skills DROP CONSTRAINT "skill_secondary_skills_skillId_fkey";
       public          postgres    false    5389    262    373                        2606    39734 .   skill_zoho_forms skill_zoho_forms_skillId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.skill_zoho_forms
    ADD CONSTRAINT "skill_zoho_forms_skillId_fkey" FOREIGN KEY ("skillId") REFERENCES public.skills(id) ON UPDATE CASCADE ON DELETE CASCADE;
 Z   ALTER TABLE ONLY public.skill_zoho_forms DROP CONSTRAINT "skill_zoho_forms_skillId_fkey";
       public          postgres    false    262    5389    378                       2606    39739 1   skill_zoho_forms skill_zoho_forms_zohoFormId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.skill_zoho_forms
    ADD CONSTRAINT "skill_zoho_forms_zohoFormId_fkey" FOREIGN KEY ("zohoFormId") REFERENCES public.zoho_forms(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ]   ALTER TABLE ONLY public.skill_zoho_forms DROP CONSTRAINT "skill_zoho_forms_zohoFormId_fkey";
       public          postgres    false    378    268    5395                       2606    42083 :   subscription_features subscription_features_featureId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.subscription_features
    ADD CONSTRAINT "subscription_features_featureId_fkey" FOREIGN KEY ("featureId") REFERENCES public.features_list(id) ON UPDATE CASCADE ON DELETE CASCADE;
 f   ALTER TABLE ONLY public.subscription_features DROP CONSTRAINT "subscription_features_featureId_fkey";
       public          postgres    false    5457    330    404            
           2606    39824 2   tag_members tag_members_openAvailabilityTagId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tag_members
    ADD CONSTRAINT "tag_members_openAvailabilityTagId_fkey" FOREIGN KEY ("openAvailabilityTagId") REFERENCES public.open_availability_tags(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.tag_members DROP CONSTRAINT "tag_members_openAvailabilityTagId_fkey";
       public          postgres    false    284    5411    383                       2606    39829 #   tag_members tag_members_userId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tag_members
    ADD CONSTRAINT "tag_members_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.tag_members DROP CONSTRAINT "tag_members_userId_fkey";
       public          postgres    false    5383    258    383            �           2606    41839 $   timesheets timesheets_projectId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.timesheets
    ADD CONSTRAINT "timesheets_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;
 P   ALTER TABLE ONLY public.timesheets DROP CONSTRAINT "timesheets_projectId_fkey";
       public          postgres    false    5475    350    348            �           2606    39694 =   tp_secondary_skills tp_secondary_skills_secondarySkillId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tp_secondary_skills
    ADD CONSTRAINT "tp_secondary_skills_secondarySkillId_fkey" FOREIGN KEY ("secondarySkillId") REFERENCES public.secondary_skills(id) ON UPDATE CASCADE ON DELETE CASCADE;
 i   ALTER TABLE ONLY public.tp_secondary_skills DROP CONSTRAINT "tp_secondary_skills_secondarySkillId_fkey";
       public          postgres    false    264    5391    375            �           2606    39689 3   tp_secondary_skills tp_secondary_skills_userId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tp_secondary_skills
    ADD CONSTRAINT "tp_secondary_skills_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.tp_secondary_skills DROP CONSTRAINT "tp_secondary_skills_userId_fkey";
       public          postgres    false    258    375    5383            �           2606    39679     tp_skills tp_skills_skillId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tp_skills
    ADD CONSTRAINT "tp_skills_skillId_fkey" FOREIGN KEY ("skillId") REFERENCES public.skills(id) ON UPDATE CASCADE ON DELETE CASCADE;
 L   ALTER TABLE ONLY public.tp_skills DROP CONSTRAINT "tp_skills_skillId_fkey";
       public          postgres    false    262    5389    374            �           2606    39674    tp_skills tp_skills_userId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tp_skills
    ADD CONSTRAINT "tp_skills_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 K   ALTER TABLE ONLY public.tp_skills DROP CONSTRAINT "tp_skills_userId_fkey";
       public          postgres    false    374    258    5383            �           2606    41815 >   user_current_location user_current_location_currentCityId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_current_location
    ADD CONSTRAINT "user_current_location_currentCityId_fkey" FOREIGN KEY ("currentCityId") REFERENCES public.cities(id) ON UPDATE CASCADE;
 j   ALTER TABLE ONLY public.user_current_location DROP CONSTRAINT "user_current_location_currentCityId_fkey";
       public          postgres    false    304    328    5431            �           2606    41803 S   user_defined_email_templates user_defined_email_templates_predefinedMeetTypeId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_defined_email_templates
    ADD CONSTRAINT "user_defined_email_templates_predefinedMeetTypeId_fkey" FOREIGN KEY ("predefinedMeetTypeId") REFERENCES public.predefined_meet_types(id) ON UPDATE CASCADE;
    ALTER TABLE ONLY public.user_defined_email_templates DROP CONSTRAINT "user_defined_email_templates_predefinedMeetTypeId_fkey";
       public          postgres    false    322    342    5469                       2606    41832 =   user_email_signature user_email_signature_organizationId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_email_signature
    ADD CONSTRAINT "user_email_signature_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public.organizations(id) ON UPDATE CASCADE;
 i   ALTER TABLE ONLY public.user_email_signature DROP CONSTRAINT "user_email_signature_organizationId_fkey";
       public          postgres    false    393    5377    254                       2606    39799 Q   user_general_secondary_skills user_general_secondary_skills_secondarySkillId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_general_secondary_skills
    ADD CONSTRAINT "user_general_secondary_skills_secondarySkillId_fkey" FOREIGN KEY ("secondarySkillId") REFERENCES public.secondary_skills(id) ON UPDATE CASCADE ON DELETE CASCADE;
 }   ALTER TABLE ONLY public.user_general_secondary_skills DROP CONSTRAINT "user_general_secondary_skills_secondarySkillId_fkey";
       public          postgres    false    5391    264    382            	           2606    39794 G   user_general_secondary_skills user_general_secondary_skills_userId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_general_secondary_skills
    ADD CONSTRAINT "user_general_secondary_skills_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 s   ALTER TABLE ONLY public.user_general_secondary_skills DROP CONSTRAINT "user_general_secondary_skills_userId_fkey";
       public          postgres    false    258    5383    382                       2606    39784 4   user_general_skills user_general_skills_skillId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_general_skills
    ADD CONSTRAINT "user_general_skills_skillId_fkey" FOREIGN KEY ("skillId") REFERENCES public.skills(id) ON UPDATE CASCADE ON DELETE CASCADE;
 `   ALTER TABLE ONLY public.user_general_skills DROP CONSTRAINT "user_general_skills_skillId_fkey";
       public          postgres    false    381    5389    262                       2606    39779 3   user_general_skills user_general_skills_userId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_general_skills
    ADD CONSTRAINT "user_general_skills_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.user_general_skills DROP CONSTRAINT "user_general_skills_userId_fkey";
       public          postgres    false    381    258    5383                       2606    43138 +   user_login_logs user_login_logs_userId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_login_logs
    ADD CONSTRAINT "user_login_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 W   ALTER TABLE ONLY public.user_login_logs DROP CONSTRAINT "user_login_logs_userId_fkey";
       public          postgres    false    258    5383    425            �           2606    41705 ;   user_personality_traits user_personality_traits_userId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_personality_traits
    ADD CONSTRAINT "user_personality_traits_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 g   ALTER TABLE ONLY public.user_personality_traits DROP CONSTRAINT "user_personality_traits_userId_fkey";
       public          postgres    false    258    5383    286            �           2606    41757 C   user_suggested_organization user_suggested_organization_cityId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_suggested_organization
    ADD CONSTRAINT "user_suggested_organization_cityId_fkey" FOREIGN KEY ("cityId") REFERENCES public.cities(id) ON UPDATE CASCADE;
 o   ALTER TABLE ONLY public.user_suggested_organization DROP CONSTRAINT "user_suggested_organization_cityId_fkey";
       public          postgres    false    5431    306    304            �           2606    41681 1   user_verifications user_verifications_userId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_verifications
    ADD CONSTRAINT "user_verifications_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
 ]   ALTER TABLE ONLY public.user_verifications DROP CONSTRAINT "user_verifications_userId_fkey";
       public          postgres    false    258    272    5383            �           2606    41633    users users_designationId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.users
    ADD CONSTRAINT "users_designationId_fkey" FOREIGN KEY ("designationId") REFERENCES public.designations(id) ON UPDATE CASCADE;
 J   ALTER TABLE ONLY public.users DROP CONSTRAINT "users_designationId_fkey";
       public          postgres    false    5375    258    252            �           2606    41623 $   users users_eventColorForEmail2_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.users
    ADD CONSTRAINT "users_eventColorForEmail2_fkey" FOREIGN KEY ("eventColorForEmail2") REFERENCES public.event_colors(id) ON UPDATE CASCADE ON DELETE CASCADE;
 P   ALTER TABLE ONLY public.users DROP CONSTRAINT "users_eventColorForEmail2_fkey";
       public          postgres    false    5373    258    250            �           2606    41628 $   users users_eventColorForEmail3_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.users
    ADD CONSTRAINT "users_eventColorForEmail3_fkey" FOREIGN KEY ("eventColorForEmail3") REFERENCES public.event_colors(id) ON UPDATE CASCADE ON DELETE CASCADE;
 P   ALTER TABLE ONLY public.users DROP CONSTRAINT "users_eventColorForEmail3_fkey";
       public          postgres    false    5373    250    258            �           2606    41618 #   users users_eventColorForEmail_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.users
    ADD CONSTRAINT "users_eventColorForEmail_fkey" FOREIGN KEY ("eventColorForEmail") REFERENCES public.event_colors(id) ON UPDATE CASCADE ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.users DROP CONSTRAINT "users_eventColorForEmail_fkey";
       public          postgres    false    258    250    5373            �           2606    41643    users users_locationId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.users
    ADD CONSTRAINT "users_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES public.locations(id) ON UPDATE CASCADE;
 G   ALTER TABLE ONLY public.users DROP CONSTRAINT "users_locationId_fkey";
       public          postgres    false    258    256    5379            �           2606    41638    users users_organizationId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.users
    ADD CONSTRAINT "users_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES public.organizations(id) ON UPDATE CASCADE;
 K   ALTER TABLE ONLY public.users DROP CONSTRAINT "users_organizationId_fkey";
       public          postgres    false    5377    254    258            �           2606    41609    users users_userTypeId_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.users
    ADD CONSTRAINT "users_userTypeId_fkey" FOREIGN KEY ("userTypeId") REFERENCES public.user_types(id) ON UPDATE CASCADE ON DELETE CASCADE;
 G   ALTER TABLE ONLY public.users DROP CONSTRAINT "users_userTypeId_fkey";
       public          postgres    false    248    258    5371            a   �   x����� �&�,�r��v�!��A��R�:F�X�#t�*iVMS�Ƚ�I�����)E���<�[�c�S���^ZS��r�-�LO����Cn0��P�	�^�\os���a�xUm�:���<���A}a��(`��(�\���)���'6<      `   f   x�˱@0���=�8qպv�H�VK�Z��P��?|�2��HBbk�&�-u޹.��T�O�K=�k����q�_%5��V��������yĤ�*�4 �v�f      �      x������ � �      -      x������ � �      0      x������ � �      ,      x������ � �      /      x������ � �      �   J   x�3��/J7���L�2�� l��6�M l3��6�� lCN��"ǂ�K]�Դ�Ҝ�L� ��      _   =   x�34�����(�wH�M���K���4�41�24���D4�4��24���4�LD����� �a�      �   <   x�3�t/O���/�4�2��J�,(-�4�2��/�I�K��4�2����N-*�4����� }(�         �   x�m�Qn�0D���Dŀ=AO���dwM"%��9}סQQ�d�m��z�'
�p��b��������۲��Stf��я[�yQ(��}a��VLU׵���Zi�)L��Q�v��g�/n�ss}�OV���ZO~c���O3�%��<���YX���kx�;vkԶy--��M���6��,�����8|�����4y&�]s"����Qkҫ��0a�®i�m�,���aW�7�ߙ       g      x�3���K�L�2�t�M-�LN����� J��      �      x������ � �      Y   ]   x�m���0C�s�Q��fN��AoH���m4��p�oXʡ#���˯h����eT���Vi�S΍��T�8%ۇ�mQa(�u�����#"�            x������ � �      "      x������ � �            x������ � �            x������ � �            x������ � �            x������ � �             x������ � �      &      x������ � �      $      x������ � �      (      x������ � �            x������ � �      I      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      Q   *   x�3���/QH*�OLIN,.�2�t-K�+Q�(M����� �_
      S   .  x�QAn� <o^1/��J��/��K0iS�&�_�4������q�gI9����~�D'?o�x,���u�P�KA;k�!؛)c¶��N�������v~��02-C�x�u7�l ?O02�	
��P�zRX+�1aK���P�y�C��3e�K�vT���{`�8���=��������:]�(m��?�U��R��t��ns��3�L�Z�)��K${ۑGu�">��M���;���{i.%�5sW���[ �b�&
�2�@R
���������0������?��M��μ|�-��oܔ�      �   �   x�e�K�0�����XC�2T�]�L�BR !�:.�-�C[�_Ο�����n8��w����U��=�"P����r�X���d�6����ܸ%�'���<+TE��$�{�܎�m�*	�$�I2F��'�o��K���.k1�������b_b      �   /  x�uSKo�0>;����Tv�F��;��ЋbіVY�$9�W�Ov�G� ����Gr�qT3`����m��(���L�Q��d:"�Q2ߒy:Y��|<��?oS�r4Lg�%u���d_�ZW��uF�b���û�%��Ǡ]?zD�yA���w��i*צ�V��=�N0�{T��8��CT`�,Ck�Z�vZ�!��9�8�������h��D��R��O���p�er����V=�����fGd��_�	�I_�Px�jz����N�QGT�6'�{���tُa˅�6BJ����
�O�Rv]UڸZ	�v�2�f��A;����
*쩬�N���j����Z��,T뭿kaZ�����uTe8�J"�9��� ���������/ԏ���sa�A�����|���jm
��_�Vm�Q4����j����ON9��8����uъ�_K���ݲوģd����_&BHز8ūmB����j�\}�1'����낇�����R��KJʘ�v5��	Ft1_,��n��s����`��yo�            x��}Yw�ȵ�3ϯ�C�[��<���=rSV�`�� +kea�*�@$���~�,�(�mY�e����ܔTU��W�jO܂_�,/2����s?��,�˲���'�� Z��������o�:0���Ӆ����\Q4�߰�}+����ӟ� �?Ey%����vE��y�0���W�W7��ˊ dy^�.���������˟k\�Y��U�T�?�;s��?���^���;��l��SK?H`p�/q��Y�W�˛%����AdxY'9^�^�A�-����$�n�ǁ������[}���q��	� ���?Or?Z?������{�	���0���
�g�w��8���;u����;�~���ܭXB��hI�j�T�u�	yNË��9�����>� ��|�r�g~P�5[��iiX߭�&ɲ�����2�yA���(�
7���<�o��9AU�_��l�:I�I@�c=<���� o4��#Ҳ��e^-��<z2yXc'�?.�$p�`A�� ����!���g���!*SY���w�����y��vF��_Ϋ��`�`�g�������[ýY���ŏPʱgP:�1J�������P���閩X�2�#�U\ y�H��HQIQy��&�fQə{H�PA�x��&����}��2]�;��YlZ��*�U!�=5j=-�(�(�Nz�za�ޡ@xE�.bv��c�-8(,j*�Y�+�a�Z�� �zz'=i|b���鉱�gq�/�]���.�;&���(M�\�SU@XD�L�8�i���'V�Ӱ�O#o`��~�MW������������+2����_�h
���˯u8�� ��c���(R��cP���ǫ����J�EP�BQ�(� R�WA*�#O~�~�1�)�=2L�Y�u�^����2i��L\9UrBA��a���@�՜�Oc�T�.Ia��0U'0e����4��Y�V�� �^�2iLΐy�.@i�/ɲ�A�H���(�J��+��t���a��6I�a9��[�C���G��X�u>�U"��D	��i]�0]�[�UV������,�
.m�V���E7�C��M���o����E��A�o�����X����n�����s�� "�_BA�Ξ��:���5S�ۅ�5��B�%�i�"�����UN�X�B&R(�ޘ�c'�����[�4���5~
�?�9]�T���`���=	�p�3����>���)�T)̅U)[>,~_�Ja���%7����>���=��I��7�p�0n+��w\zb�X-T��*�S) Z�'r�~�e��"�C�|�?ÿϣUQUE효�X�A��O�:
1��U�!�/˖q�b�xHs��m��B�̒#@���
�������7t��aK �׶tk��g ��� %��8YV���5{�L/�D-��"8�a��!�V� D�m�9p�H!�v���EA��⬌q�:�����il�4쉂t��qO���\��@�yY{��w�	�\�΁���"�=�5��"^s�0N���� �d'�EX���*��T	E�I�K>tŲ�ϒ4�e՟�A�M��|�/6-��L�u$
�ߓE�2��4Nhn��Nz��N������f�K�I���Ģ31�R�l����o2�_("'��V��
�'vut7����[�ܽ�~��q�w�Զ�6�B�Y)TZ�+�����?r�Bs(�.�p�w�^�FL���Ȟ.eU�aRf�K٤Z�"H$��S�0����v�3��L��Y�)�R5IV�%�1*�8lz�D�w�����s�݅L���ɶ�"�B��4�\���7<����O#L�B�Boz�w�^�C�磀q[wQ,�qU��3�)��p!h���	C�9N8���9�� P��Kn��Y�m�z\�������g��GbDB���Sy7�PG1�}E�O#Ԁ"�"q��w�=�kr�\�� �"ݡW�˪.�?f���9�� ���::b�׮�)�e�,ή��lu�=3h�֙�+����	�W�X_��re�m��]����W5S^����]{u��H�l��`���?�2�%N�����ED�#:7����.=Y�8���g��	N�	�)(ǘ@�g�%��\P���*��t%��b��N�m�����1�?�����"$h�ߪ^Q�R�;��j>�ywo�����>y����nש�����p��K��H�r{Gzt���y�	������}&58i�Ӟ)�<�{fK�瑦`������/5��������Julo>!�c��榿�|����u�Z���}a��ջ�E�*p��Z�O��p����ߊ��<oB��M~:�;dCI��DG`DM�MQ=Fa=�|��a��ͼG�^��Q����4��x�|�,��5�т�X�<0Oެ��������2#Q�?$W��5x��++Y}�]������X�XY�~�'l��.��]=c�
ή����ʌ]'P�mϮ���lg��ǫLyx�7_���=i�������M	��	[�7�2�Mn6�V >���׷ٚ wvl���?��f�om6N�@)�D)@ݩ������a�1r�T������='��������ѣQ�P�P�|a����������Q�P�P�|!zƑX�`����z���K䵳�zIW���1�,�L��PK[�p<��*B�iK� )�N|��Nܬ��{�A��C�m��<�U����e�;}�(ӅV(���*��A��XҚ��o�k+��ñG��F��Dm���*7n�/�sV��.KS&��"R�R��Z�Y^�H.�6B�<�j��{(��n��8,B����PyjD=y��������z�	��m�[����²�_m.%{ca����5��qg_| 4�x4Ļ�m8�s4�6�m��m�!�q�;(�	���mk�������/,n�+���	�=��:�Ycs��'h�R�mOs�C��r�is�<�6v6�uOz�p�$/����76�V1�t�6cl�>���<�jsίM�o�h��7�k�2�#JpO�K	n�&ګ��ͅʄ�c\(�&>W*�7R��`o�YB�X������SB��������J猋�zGϷ�P�O)�R$��;�T'�|�"'we\�$�8ol*���.6�l�7�	�>���0� 1�:y�0A�_1���y0�<Hy���]�C��'Bn(�4T���gwЎ��a��P���''� �q�s�~3)���եd�g�2?$�_)���+3���xm�t�K��ō@�G���qRL� o��(�vL Z7�)��a�q9�;��E;嫞l���H��g�\2�Z��eOԢ#����\4���zu�٦�Q�xz�t��{%�+o�Pǣs�\��;�A����پ�\[��㦀q�`Ѵ���-�a�$��U�A��[Z��z|N���0�Ln��^�O[��o|�GRrx�����|�+����js)x��cl��;}u��9�U�1J-[B�����Q�`P�Rv�^�yB���gm���6cl����X�Jߣ��{` �����տKu��(�=�p	=vQ�;m���#�˂�ҭ�����v}q�Z����f� �2�ľ8�:���#�yk����(�=Mo)�7Jo�Mo�8�K�x�����2$��/��m�T��cv]�����X-�F����i݆s�h!�*p�'
H堳ƾ�� �i��5�����/G$
:&pv�n��RȅW���׭"���fA�">Q?��( ) O��4���ϳ�_�S�og�:r�:+�mdm���md�!��J-�����cc�)��3�6�E�?����rz�w�'R?{�q+q_z#( ��9Ig�Ο�zz���f;���W�ܕI����u�����Wg=e����G�N�0�|B9$�7�3��n}�!��slol4����Dl8����s�6��F眽�HC�a��2e��f8u�p±�?��`8t��SK 'SrJ��!ir}a.��9@뜾��Z���'Z8���(�Q�;m���ẇQ
��kӅ��    ��
�|g�$�������P�����^�7��zu�k���<%��ɭ��F����Mbɍ�f����ɕ�m���s��'�
�::ǆiu���֖`�'&9�fK��F�А�M��ivk(�Qv;iv��0#���I��D��#��R��v��څ��
?/��<�Վ��3}�/2�󅟕�����kY%Eu�' 7�#�D1FT�M��?F���/��%s��}b�1k�7gA�|�	���כ��F��a��i}��ȼ�dN����\�'�6߯G�\A~-����ᾥp�p?m��`Xq�?8�<�w��w���>w�>�{�iB�������.=�ޏ���ཧx�x?m����GB�;�;K�N�~�xWy#�D�\��N���%�����vk3�ja��v���#����Ȏ��K�6?"�<��3�pG9�r�Is'K��ˏ�(��ӽ�@˄BL�Eᗁ�B͋���Yfu�(Iy��eub��:'�%�Tߘ��w�p^<�I�W�����3��8"�\��!�kNG�[J�O�:OI���I���Mx��E���io� k��vA8��m?��\��I(��f�+K4��͏	幧yN�<Gy�yNf'<'�9���+�B���0��6��}q)gw��p�
qu�u�fk�1go>&6� )�=M"�?J�M܄��c�'?E���2���{h�o��xM��Ce�L���7��70�K� G�5�G�O�D����i���1,�?�R�����0�Pˡ?�2��lg`t�% y-���__�HϷ�dh]�gP�H�p`�shpO:4������c�@1a�HjwY�%O���}^o,a�:*߈��=f�a@�2 e��f@^�n���r?=�
F����' �+�?f�V��x���ĩQ.!N��T��TJ\���]kqB���;؄wCo���e����{��W��S;wwS��K'�~�y�:oȣ�7�b�<��-���˚����ܮ�%{����a�n_G����yg��ᾓV�}���Ey���I��(���4��\3��`Ԛ�&�`� z��}�e:�`�i�B*4���2s#�5��B�i�\�����Iy�I�&�7��.t�y%�@��Z�DV�W��M��T���"�$���bRcR<�RG���!�X�)<\�<º�L�+�ۑ�
 �K%.+�MK���@�,rU
B
���:�|9]qRN��˦kp83��e��A�����rӅ
s��n�6���VsŬ�j
E
�Ӆ�vE�X�aU�׆bUl?�f�4�D���"w�@RE���<��۰��'E�]p��y#�ea�D�S�ҏ�lʊ)w�ˤ>\T.���h%�j��*rͻpgC{ S�&��~8�=�&5���Y�U�
;!.�wd���7�Pa�I��ȰP9�Wb���'B�Q#�R�i���&�ȝ�d`�7L��B��'k��q��������9��R|�Ǟ�[��~k@y���mΔ0^�WlI�w�V����M��d����
ȱ���\���k\�����E�|.\u���	��.b�̂E[ՉX4q%���h8僊���1K�z�P�'P�Ͳ�<T��ۀ��]�CA�@�-�Z$'�����&9Q�z&)XO��� ^0ك�P��A�;�g��@�h���~� �u�3�� �v`�@�J�.R��w87i�D	��Iy�
Y�\ݭ`C��iB<!;D���X�[� g�2��-D�
|�������m�J2r�S�Q��.��C��Ǖ�
^e���~.2�M� �HZٗ��$�(IJ@�U)�N*��F�Gy��掏D����v1J�e�-����h?�qW�9#�.tͻ�P���o���!��l{f�N�3�V0.���Op�:����+�l�K���Z��j��z�/��ꮹ�~�zg��?~�e�K�bk	�|G���:.�p�ɂz�9��� P̟$�Q��m�h�gi���|�8����:5|�z���eP�tLV�GF��^�K��C�j3�dէ�I�܄��+����m���/�΂k5��1�M<��F����M��
�䤱�x,��}�󦛧�cp4�1�ma���"%��UW!T �H�q��J�'�A���1��p����o���+�/�j��EY$E�j�fI�z�����	�pSųG���A�������fA���Y_���؊(cv-��~]_�s|�DP��LpU�R$�2��x��_�=:n�
ԟ���0�_o�}
��f�8\:$kR
[�P@�(��X�|��������Qx�v_o��:t�u�B �F/�'��t��/�f  ��,�[;�m�{(���������7�d�s��i;^��\ݩ��&%�'����#��I�^p@ry��~��蜱J����{�5TU���j��%�ѧ�p!>�3�s���S)�Q�;i��FE�>�)�/�����G!���Ä1\�T��+� (f%N(�D�'����O�b0�8b�x�9D�pW̧�̔N�#��#�0� �n#ƜV%��q�k�NV��j���c�45�_^8�	��Z2g��#�:��C�+���^c���s\�ӡѯ��������uB��w(���՞�5m�,mPU��Aw$�����3.�{���"q%�j�(F����*FI[�Q����<MDj�8K�=g~+ْ�6yF. O�U��~�0i�v*���ZQJA�%��Xe�P���EIyr�|���푷���6ms<0�jt��������E�g���3�|���Fg�m���dQ�OQ/�%@��9�_��q�կ87�/����'�ya�y���%�y�����~�T��"��A`}{j�S؟,��ث&�����~/�Q��8
�T%��P%�����&������� �ڂ�N�8Y���1��2q�"�t8�^�	|����6��w�y.�M[f�����{�������٫w`��cѦ�O�S3��=�}v�h�os��{���_�Ck��~��C�[�:Nz��j]��/��������1�͗���p�D�<�.�$SJ\��$WQ��0OJ�i�����Q�Tϓ��8�Y<�&q����e��2�S�Bh%9UI)[�k�P��(s¶�X�K����帪����6�[��n\�`�����]��K@AT����q�~�Ğ��M��|��P����3����q��c���;�@�E���d���C��L�;��"Q[Զ[��-�jU��q�H�eE��"�c�	T�cP=�1��9����8���8`j�\���%�Z$8���&�T4qE��P��2N�	N�c8�8i�d�荐ڵC;bb�[ �R�����#��j$.�(��/E�)#u\�Q�G����s��r��+&+��)zgJ�$�nB�Vm+*

U�lDIy<�ۨ̔�S'��va4߅s\��x#�m�lC�c�^}"[�2��|(�y�Y�p.ޕ����y��(|h�=ӣ�Vp`�W�w�m@x�h��aRؗL���,�N�7-�<�ZL�R�)S�4�4ԓ��4�z�j��g<�xLF� �5����G��90�||'>y��ʹ5������|�0��]�r�\�	[���+U�q�(�(�N|�d�ӎ�|�Μ�Y|Ưj��|�(m���%�Z�Wn
�)�O=�w|�Xۜ���n3��=C��B*�B(���e�!,'e�j�&!�s03����AO���,�n���u�)�8�B����0��l����F(�(�Nz;���c&'<@OT�ˁע��P^3=�����4Gh���$!EN�)�(�Nx�!���n����L��ӗh�5ER6�����+���O��?�c+y"�w��aF���Ecs��zǲzj�W& �y�����O���E���h���)��h�0��#a��<��D�A�E��¹�J��p4y̽��W�Ի}kt)]m.;#=�Fj��y���'�qF��<��h4��    ��{t�;�}����}�V0��񦬦����3&Z�u0��e���l���F4x����,e��YQV��vڬ&�YM>�2��l5������y��+�5V1^���wq�^m�	YXX_E�џ��x�a�I�՞f���e��f5��V;�u+�N�f�����nzX�8��/$�s��7�f��[��@Vo�F�њeϰZBY���i��<a�����	��oFk�2�޾��\4~z��ʌv��c;����Sl�hk�η�֞������Ӧ5��1��G�ڒ!�[q��1R��v��yc }�6ya�H݌���k~j B膚l�p[F��r�)s�K�|�K�����K0Z��g(L{���LV����hQ���ڍ9�IэB��	[��}�Żn�6��ߝ~*�B>ɟ��Ϣ{�TTUQ�&j�ր'����B��J�����X�K�u��+ }s�	�C}�zO�#����=��N�����G�6�.�N�]��@g���� f�1Ľ���R$��N'�r�?����,VoQ�3�VPn��v��Ƴ��m6ޅFq�߇��������~��t�9����r׬�tB}s�Qn{��J�m��N�۸G�&�ۤ�j�Y楤���{�w��xK�m�����ӑɿ�A�G��in�(�Qn;mn�sۼ�&��"���fz[�o[������)��_mާ:��������^�)�=�m5�6�m��m�~�.����2�o�D���>0.����ڮ�ۧ�@\ڧe\|J-�����^��ĲgHSR��vʤƋ��G<5��¸�5a����UN�*/�-�*�����0�Z��Q�)�̷0�K.��o�$����~�hyXb_2���?&�9cu������6ӫ���zz���yg�>�@���Sn�����O��9~���iǒ��^���hM?���L2��mdu:!6����h�/�y��z5�2Z�z�1���4����(��6�������\$���~M��"$F`�馅��zk%_.�w
�b|�ض��(��6�Ԑ�Mv�x�<4Z�O�x��_^XЁӇMF(�YB��9�e��u�j(�g��B�B�D�7� ����kAt1�"b�-�$�k�[�he�k_�.D�J7=���E��y��P�`��%�d�}��3�.��w~��!�Y�b,Kl�5U��q�S�Q��,��I��)���u��>��r��Z�D!�̶kq58y4��Z!g�:uB/h�)�(�N~�(M���1�+7�����聓��뼮��W b�Vm�(����"��/�c�Xl+N�a������g�O����ђ40o�.B1�.����ôN�0�v�Fy��Z���@�u+�ibGNzu���M��7�{����ܐ�=�f �J�E�V������ƙO��uO�u9�.L��\��Gǂ.%�d/�̑�ov��ɾ�Kz�����U�]�1o���6�x�?�HgdS��3���PN;mN;O��H���[�a$_�}�[4[���mmF���b��Ą��!i��|J�6��{X篹�y�����)e��٭��F����mR*�����4f78��yCn��9om>B�X_�K	%�:�WB	Cbپ�_����؜�b'�p[O��r�is�4q�mYv����%PXͅ�Mo��:b����a!"[�>�d5��<U}M"I�1x'<y�|
�2���߿�z�2��L���8Rڢj2�n`��.v���s
=
���$��ac�:�d�y� ��c�^������roA% _�JE��L����( ) O��(Oܯ�{�+����uNg7c����<��)���|�Rq��@(ߢ4/��Y&��9��^0Z�� ˸ʿj�ήf�����S��q�R�(�SRC6(�o�p>o���:�p��9�%���ہ�IˠaB�-�0k�S/�s��A��m��AD�ΔqO�q9A��f �T��W`�9°g0�&�`��i�0�%Q�TESJ��y��'�A�}�A���6�,ٯ>zdA̠�)��)TNU/a�F����JF�������Ge������H�W���E~�D������x~PA�j�ڰ�J5EE�颏�O����ԉ������D/��<���mĠ�n�~%%B��M��a��J!F\݊�ڍ���'L�'��<�L�0"Û���B�>�� ``�,�Xm�jm��m��Bb$��L�`(�N~�������׀�H�GE���^d��DQ,�Y��!R�G�R�0���;]�I��O���<�/�|����~��m�T�����P�%*�r�n����+��"�t�����`f�4��P6��Q�w�D�r��W�P��]�nv���c{�C�P�4���r���MO4��_�.;���Ѡ��Aթ�ŏ�֍9� (N�P�`d;�AEw,�]� Sd�/跋Rd��j�8�`B��y>d���8��ӥhQ9<�^����}|�A�Dm�3��EͶ���|����<��F�������ѧz���S�AA�ao?�~h���>v墅��T������BnҸ
cꞢ�;a����8����ۧd��S���]ⴰ&+2�V8M�_ �&l��X���E.�(sE_vDO̚��0����x�IQHQxr(��	
gCo�oB�0�A��E�1U\-։ӨT|�
��J��*����ISR��aRÅ;��[��FU�FU�m5S~-W�,�(�}��>�����(��ej��H��OD?T����ը�3��`�fÝ�aw7��e��)���q:=���󘉻�BKɾ��a�5�	kE��*.&l���l<;���ܤr��,�&ݛ̭)
�mʊ� ^�r�:) ����WX�lͫ[����8�7&{+��ܜ�a"�a��y����}ի�8�V
�H-���TT��'!��$�G��9��	��I2��������=YB�LU�>��p!)y��+I~�9�H���Ɏouy���Y6�F�M��P��?o2Y��d�fޢ���yXD���*DjT�U<���*�&;��{��$�{q�6�*��5��u1M��@�DU�����TQ����h�s*|+xXXh������{��c&m��DY�(��I�"/!C�m'����&���MVO֫ћ�ҭ+f�mR��B���\WմJk8NL�X#ƀ��,ev2����;��,�$���������� �K��L��ټ*ǑZ̉��j��?=K��,�����o����oc$���y�2 u�����.ˢ�Md�k���rQ|��d~2a�؄�sA�"Wꑤ�מlZ�L�o[&h�EX�<��
C��8�E��m���d�G�=¿�X��~�H� S�����r���.�
P𲧟��O<�ʜ��N�
�ۣn���6�%ی�mh�]�L�蜳��^��Eݰԣ��G}{ܣ�<��gXnr 8����ڸ�_� WE[&����F�L*]FJVB.�~�*+]9��9~�B�t�)�ۄ���N��F��Qn���m��%	�}���2~�.���5�K�ZUaU$a[	BR��C� ЌG,MF<[�y5c�O�k�|Y��{ɐ�]� �
fɐ#)�Zb#�ˊ�s(�T���*Y>2lȼ�)�
1�* z���1Ͷ�c�XĒ�U����Sɹ�ּ[j}2�[�>�2��5��<5l'� ��h59�q�3��]���jB�B-�,�8��J�ݷ�\�r�mO�nS�]�����.�y�̗����W���<ܝ=��Va�Hk�`r
�\���II��V#UK���0��h� ����έ��qҼʎER�����V�����x΍B%]� @R�?�����K���N��?����vz�I��)p��0��V>V�$($�i[W�+">Ώ̄�7x��f+�}�T)�R��Qׅ/��|4��N���{C�啷Շ
�f���|H����	b#� u��0������ro p�-N����H=ğc �PE-����^C�������_���5���/t�6�X����'d�n8�!OkH����4d�
o�M���
#��    ����}̭M���sl�<i��}�W���zca���n�� �`}q�SyZG�tD|�#3�
�Mj�e w��!����W����ک.���/,q=��6u��1k\\cݴx���U��.RyZA�S
"MD=f���x	�l��F��c&�z�.��3�#k��Xf,^m.y}��@�q�o����.��z4O���H=�X!��9,`�tQӂ�A�5j'z�� �>Hz��j��cs���Ћh�tyN?ڧ�C9�����*?�~�k�B�,�A��[��ˠ��+^��տ'6��X��2/y�O���)�P'�q�?���8�����5;,����zz���R;��ur~�S#�W7�e�O-�fKu�i���m��1��~�0ߥ��{H��膵���7l��@�,l�|dl.wkS,�����n�O�6����	=���^�M������8�#��/�tݞ�b�3 �e�h��b�U�m��JVj���J"�S?���W�3S��{� ��x�%ǵ��9�_|U�뜾�8�?�}�C�����?�9��)�l�N��%=�=~��*TC��Xi���hG��h�Hi"!=�c/1��Bq�U����Kl���`���za�׉2�d�`_���:��Q����)����:b>t��7Cj���~i6�د6��~#5R�,��N_�ѝ���q�#�19(��%�`S�_�&\�m�_�/dk��K�_�M6&{���$�X�CɈ�&zI��R�yZw�ݩ��N����6�iF{xeRX�q���[���z��(�'h����u��V��B�%��[{u��4H�U��+]�J����*�|�D�F� 80�A��A}j�6�?����%kGHb�詝GIbw�ulb"�1�6��_�H:1���<�?ڳ��LHh�����B�PE,��,
��� �c�1g_X�e�����de��k��A���hM�c�[cc�f���ο�՝q�א�:25B���.�H(�o�r����1�)	Bj��H��cq3�Ȣ���~p<�q�'�<>�A�E�*S�����c��_��P
"��2�I�4�2���ϲ�)�}q�>��)Ď�-c�'�8x�9�`�>s���N�^��,�*ARP�IZi�;�x�[p���d}�|�i��6s��x_~W5��OuL��ۇ���|c���~qv=`�l{f�lIgĨ���_�h�:��$�˕y��%��q�r�����Ϳ��ګ��F�e�;d���і�.q��%|ؾ/"����������g����as���{��M��,���+N�����Y�{`�h�0N����'B���0������go>&�딲�����쀽+�U~7֗q=�M�2ǂ�덌��oo>�{�*�(ix]�x^1>a��I��%�䢠T�*E�ZD�������E�#�[�8���:�M�_x���U�%���_cb����,�^Yy؜���x}H!���%g�����z�;��+��`�2� Q�7?ʕoj r�A6Qc�!��H��ʌ�<���㝯�#ґG���(�/O)�<&D�!J�����@mP���}�Pzw���+c&�v�U+Ԕ�+*"_�����}��1K
}I����L�/��A���%��<ɿ�Ag^�L�>�j�W!�"�񪖊%��aM;�����I��k}���k�w/:�_u��P5d���q3O���n�hθ�԰�X�A��-�N�����Q;���Ѕ����s��\�C����h^on�+�d!�?��Er��uz�A���E�+0F��(K4� eNE�)#�V�8R���Q��+fW)�m�6�����G�M���jP�Z���4��8|d��p
��U�«�W5�b�F�]L�?���k�ԙ!h�G;�� ,��66��{F�/��rn|]pێzN˅���I�&r�q녧�f���|�j�*�2��f����sa�ݧg���?�̻�p9�40W���7�<�,k��>����9r 
X�rC��8 Ԓ8?-~|���������	j<_0�"%�:U�K�@���v` ���y��f"OVM��V�*9��m�*^��P�45�A��c�^֊�E)㥠`j�_�\�Oe%.i��˔<f�F�5v0�n�[�l���Q��[�A������$�9�L�� �m�E�M����:��x�m�*�n��Ǉ-}�ծ2�l3�2�h��#6-F����<͏{jh��j�e �`*��n�Z��rjS� �����T�[�.��r��u�c`-@�U��z�J�H,�]�wP�����e��0e���1m���a�	�2�w#E�R�b��wYm��(�y΢tr�h�P�#��8��<	DWģ�����]��#��{��ԡR�_+l�X�FvQ�8$y���e��đ`���Ķ�s��}nF�4���#�ǣ��b��Ɗc����_^4�#��d{�z��d�?�n��������;��zQ4�xa�d�w�:y�%�����v�3~�%S�^2�ђ�2�i���7�
0����X2���%�&Kv�2��hYa�b^w� ��A����%;0r���9-��a��܅S�N_�@R��i�dK����xU��*�)�6�n�FI��s:���g�ӔI�c�T�[�yݩt}���o��Ƭ�RH�D����R�_�0�0���&������� 8y�7w�2�滦��P2-.0;p�0ž[E��9d���b�oj�aJ��I��i���F;C���҇K�I����W�T�k�k������ʹ���	 ,X�<�����%��)��5��g#nc{ĩ�e搉��k?� p�O;����!�Q��",���(�8'���Y({�n2��l�[�hB[��Kϩ�W�Lü�]����PU���+x��^�$�#������^�}A!�}\��`4�\i ���J�A:����^o���RB	[-\�jd�l��*,Y���Be�!v��ǀ�����o@>ɟ��Ϣ��JV�k�f��d�c�p��(i:�D e��
;��a�c��Y�M�JB5jY�y䴪��'��Y�q1;��K͸��A{�(��/�U=^���_� ��2U��L��Q���Cj�f�H��5�ˑ�~���|l��{�a٫�آ<d��1ۼY���R�E�R�qa%�\5��>�a�;�����ˌ�����!�=ɷA�N�"�n��o���ڦ��%^_�e4����D�sl�7���T<�@:͕y��i.��FE;���$ ��;����^p��aꪎ���_�0��\w����-~m�O������հ�w�	���c%`}1�e\v����Q��O��c ���jpcՐ�T�9Ր�d���ϭ ��"qz����%���^�-�ݑ5�`�:��W�;�J-���^��Gh�^��֐�+;+OZ��ș���£�L�٦ł���1�S�B��%��W70x��d�g��@8\�%�|틄0f<�c&ە�4�#-k� e-K��։�GR����k��8"�����w�Q�8��3Q���;���WS�Ա���Uئ��H�*�Vz#�d�J�وR�Q�8?��uq�V��xa{�Z�D&��x�W�$�<�+i�W���`N���U,c���d%"
%�"M7���$C���������Ɔ��?�X�7S,y�X�1�R&�U�x��P�n]l�bJ�+��3c�Ôb���͜/����dRt#3��I�5������}�����@�V7?���*OC%�fPQ�Wiܾ&��U�^0J^��e�'0���>�*���>�+)�j�e�V�p ND������_CNMx7��J~^��G��:�S����I�i_�H�����6�Ӡ�_h���UrA-�$�2��J P45}��}�4�đ�i>�Ƈ_5��n��`���薋�J1+�	�&*N��N[����������e��T~8���;w�q+8�ָ]��o|c�au��؆ ����fg_�h���ׄh#K�/>����ڥOp��E��ᶯH�2?�,�fɏ5k���j�ڌ�nq��    ���C���:��Ev[�����A�P�j�ӚU~;�q;5�>�)y�b�z�l��p�>�l4@#�D��z��h�_C~l�&y��9͇yF��o�`�D��c
vp�5�źU����7:,����-�����T.l.wЇ!�ۛk����������v6_xU���Q8�Hp\���[^עe��Z�����չp�!�f��w��_��@*کN}J���v�%?ү����`�=N���u�N-�H֫�_���C��K�X�N�o�M��SE<�=i]�g���v������$�~��n�E�/�N����w*�ؑk�O��B��M�{���u��~�1~�מ�,�o����[��8k(2���ے�7=Q#q(9Gt��!��zH��%����G+�>I{N��I���zkN&j����ؖC8���lzۡ!�p$^_��| 6e�����Q��7S-��p�|L�^0�Z��ֆ0�$k_���=.%bN
�����ζ�{��}LU�i�꾝jq� �!ě��4	Fg��E�˷�F��8�#I��Em(B�O�ׯ��+��y=L����Ҝ2��i�D�8��D9�9X{���i���K��K~���>�?<�*Ha��2p���/�a�.��ja.j�]����{r�m�����Hn⼩�򂻻��u�DM�Tq2.�.�A��CG�$�׍,�)�>�W������z�)}'�fg���y��U�*��(�(r�X��8�~��OpF!�Io��	�����^�_8���(�P�"*O&(`��+E�'K���菦<y��+����&@f��]����%Jx!��}���Փ��u����H�G:�8�#A�U�JՍ����@��R���jH�'xx@��L��`�x�6c��_��󍚰���n�����^9�k-���U˽5H�!���C���
�	�9L������2d I�5�Q �}؈tUnf3��0��Ƒ��N:���L��\_|����A4&5zQ4�����5���&�.\�Z��h��.�xϯX�l޹R���Q��9\�����O)?�^�X�PZ�fi�@ܾ��{�+��,�|(Z����ʏ�}�>��ڼG�y����7@j����2�X4�8'���D5�c���FC��¦#�40�"�MuD�-��/�!q�2Rcߥ�N����������|konv��9mS����Gu��O(Nґǂ��b���y/pp��r��Wp�d�͞�3��?��9Dx�`HX���D.%�b�2�wz���f��#[}BAn~q*����^C:@�����}��ʽ�����T�A�sfիҪ�D�eG�W�0+���_o�����`'k�F :���5������O�h!�Q��7�d��O����:~߫e�R1��iQ��cf^�&�ѡ�ɪ�ɪ&+��)SU':6ST�^�]u���͸�7�XO?���������/b�]|B�*�mI:��G�c�����t��1>�&�'N@��G�E�1&����cu:FY#b���P��o�������+��k�lɻ�{٦!ٚc3��QUzZ��o�J�H���~�wS���W�h컔�O���W��S�H�k�$�̛�XvHOo����*��Q�W��4�6��p������Z2��i�˶Fo����mu+�$��2tF�O�z54�շz�Q�zZ�~��(Т�����BQ�G�����FྐޠO�D�惢o�;���*��O��#�/tl��D�&^���*"��%��X�?$�i��g�i�m6;�:��鹵��N�tt�#�5?X����0� ��ث3�Mg��y�����i�g�����w�#�z�r/8�'��ve�Cj�uo�����w
\�pCT���g�d!}k�1��h��s�������u�n�g�>R'�%��w�#��{��.��Nw��-h��2r�#4֯/.���B]���5��,��*p�����U������W�Ti,��~����
�,̫t��͒����|�u��%p�ٲn<�lia�$����8����v�Ͽ��8��?a`�4��Ӂ܏��D���o����co2a�&�}�̀�?�� ��[�~�?��3���a*w�58��.�2m�j�f� !�>�8,���� �����iɷ.���F�k9����	`}��[�$ˢ���_;/H�A�E^�&��~Q�,��o�`�cT���E̖��4������Z�
�&�G��:"-X��^��2�c'��5v2/��H��a$˰
��ߊ�[�z�	o�.U����x�������ogT���弊���чW�~������^�xM`�IyB_���E֞��C�Pἤ�%Q�W��@�Ź8d7��9�O�5�n�5�V��O,t��:��놧�Ͷ��v&���AfM~��ͩ�8��y���A]�ZR���'h�7X����7��G0xa�ڗ��ۮW�;�'��k�|{\��5�����¢����[ʪ�%u�RVI\�H��eJL����槿3��w�lZE �Q'�΋������g�/�'.�?ŋ/^|�Ӌ�<���l� �Ç�FB���ï_��7���QNL��X�>Uep�6.�TZ&R�3E�L�u&�[��e�?~^���w�ݯ�hs��Ƕ����_�ʿq�W�T=��5�����3?�#��]�#2s�������������|M�������������lv��~�!��a��������_N��?2u�x3�.2�}_�e�
vPf�9}���q��Dd{������wCB�Cn����@pK��=C�݇/�oo_��P��$��I�X�b�Y>G�����3ō<WP�v�q��O�5�Z��~�!�-j�e����0d�����}��w_#�u����Ӄ�i���r���.E��3���_.z"���b�DP�
�Q���ƋZow"�7hiV(o�?u�WKh��oW��?}�;��������C�����l���y��ߓ'��A'���U��H<��G��v�o��W�����mN�P{oV\�7H��Cl��׫ۣ4���:a��u�D�A�o8Hg_�]u;5o� �������?m��k����ƿ�[��峪`3n�$2�6;���إnM���U���/���{d����������������&ż���Iw����Fg�?}�F"T�������Fc>ǋ�\����L�.iRt��&�H>�?��]����k.nG�Ǐ/Tp��ZWm}�tw�b�k^�sܷ*񭜮�}*�uǋe|�2�����/~��A�j��Y��Pѡ���,5���w���\+�Y%�1^Lp���"�]qq�a����\�2�r��2���S%X��F~�4NSi7Q�U�q���}.�k.|�	z��B�!N���Pr�F�=d�G&J�b7�Z����x�Lq1�����F���!h����M��U+�r�/]�2�}�'l���+Zb�81�u�	.�s�^s�i�xQ��}E�� ygn�J�����t���ʕ��3�������}.�+.nz�6����=Nfc"?���x��.k�#�p�@���#��x�����_���ƋB�%�[��2�ebA�� N�#+��XjnV��u�G&�x���X�|��R^>��/�&��ew䘛^��5�#'.�byF�l}�B�)w\��>c���V����<h��bi��3Nr` ��<��"Q�Q�����p��\Lp��}.�z�O�����$�k�*�ج%-�.fq��r��L�:F�q��}.��>�z�G
��Kݤ\cOK}�
�8�B��M��[�%%p��1����/w� c��ɧ�?��y��9ep���W�M��k��K|��St)7���c)����}.�z�ӭ�[�I��b�0��1\_���_�?n{���B��Y��ҙ�]��5����X�|��#O����Z�YN��s��B�m
�d+�GDs�f��>J�bo��}.�z��y
�p���,��Yi�'�)�|���Ԗ�q��5m��&�X����If�5ȣ��r�~���tY�    �kF+�$8.�BF���v�s&�A�e��^�՞�.V$�ɘ�d��H�����o%���+�o��.r�S���皣<U���g��s�8j#�#TT~*����u�+�
tS��(� ����}=/r��2Ӕt��H�����
_������U���g!�ڸ�fc^�`���n	��!5�4zfT�~*�����s�+�6�
�i�D��s�q6v�p�ni��h�H�c^1A��O��5�c��a�Ͷ<Vb��
���w}o��v�Wp��Bf�`�cl������/^*��d���^���co���5�@� @��-�
_�y���Tx�b�n��OErM�/V$�k��ɏ�2�-��P�Gt��1����fUQCL�5���
rE�}��C�X�D?�ͥ���ۮd{\�u�m�V&��ͽP�e|0A��OEzM�/V���Bї��oC��ۊ�O��<C^ѻ7g-�UX�����,Rq���O�Xۼ����!t^a�������d��pY7:$�e	�/�i|aVǵT��O�Xۼ��}���Adʊ�ۯ��z�yw���������p�F�H��O�Xۼ����!t^a$�P8K�ͻp/E��!V���X��yU(́��X�NP��T��͛]ߗ�}�M�i�A��I�o�w)��s����;)����)*��S1�6o�|�+�JÁ�� �mb�Im�
�tyP��+�H�����'���O�Xۼ��}���2� ��$u����,��u�6[>p���gg�MR��R�]k��1�U(Q�f�*�;בU�<}C_�o�����*Tc�o~*��M�����l�Ƹ���e�E��^�y�o����[Fb�'ɣ^1A��~*����^���c�A��7�j�{��W X0�g0�ޣ���O�~*����N�ˇ�>'��<C~���ء�Z�6Q�(�\nwsn�խH�}*v~*����>�����6�p�s\��t�|�g�`����l&j g�~OP���k�7��/B� �6��T8m�B^�T�]�}���p�Ԗ[�2�Q���b�b�m>�|���>�2�v�V�?:s7NGjq%l	�r�g�6G�B�+�	*��������A��� LC�I�M)Cϴ��
�6�Y'��v�9��+'Rq���O�X�|�� O�}����C�s������6K�����݌�V�����X1A��b�m>�|���>��uGe/�,r�b�m�8������&�'FW{.���t�
�b>�6�|>�ӿ��lEg焵�U��l�+�h��A�E�l��>1�y����O�X�|�� O�}F_zFdZQ����f}[9�+��*�7j�q��$?����6=>�SxD�'�!��APg�R�8�n��������L��X�NP�w?�ڦ�y�0���'�o�+
5��c�k�2Q�*�r���;A��~*����y�p�8��	v�B�/��vT�� �����u��vߎMP񋟊�����A��� ���ӌ��AM���8���^��H.�9ċ��v�	*~�S1�6�}>�sp�*��9N%�c�wU���\��mM�����**ޓT�T���g����ϔ�^,8L�fn�3����$��eE}jRf��)*>��k��>�9���[/I����IŻP=�ѹ8�u=�w"�$L��H�}*>��k��>�9��q��^@.�C��p���l��W�̾L�&8�"��b�����������A��� L�R)�<١;{�@\��m���W��ÿKe�b��'?cm���<��A�ސ�?Bu�3��X�Tp�NŢ���l�ߤ�N���T��T���g���atT��8�ߢ�"Ey|mW�b1�fn���s�&��~*����y���`�ݝ]@\P��ł� ���y�R�#d�)T�)+b2E��Oŵ���A��� �e�@I�ӎpjn�is���`���͸Q{t�"��H�T\k��}�m�~��^�#s;c��� ��}!G�Le'֪���Ul쯘����i�_��G��m�s����Tyz���[��X��L˄�A3g�MQ���x���+B� ��犾w�򈱂�k�9���a�:@�����os���O���}����v�	ܒ���R#\��.����:Q2�T�"�����x���+B� L�i�9:����7��T8R���.�����:�T<x�x�]Qq���k=�,5�� ٤���>y�V8CO7g���(:�]T�'�x�S�\Qq[����@'};g-&��xk��z�s�5� E����&�Ś���O���w�W��B ����rz�#8���Z�����:E]��	*��T�WT�V��C�ʔ(��f��b榰�<�Y7�3ոde��4���O���Td�T�bEhś�,ᗗBI֮�W�M�o�*��-�+�u��LS񍟊��o��C��G��=褗�{b���N��7_�:�p2R��.(x����6=�w\��EW����ۓ��k�ީXr��Wtq�dc�)c^1Aŋ�������$����/�;V��;��X�a��\�@�K�I���D��8E��T���ħx'�oF��*��?���p[M[�WX��22FK�!۬�&�I�����k��O�N�+���'ժ�jq�T�^	1�p.V��
��J������E�A&�ȽT<���ħx'�oޮ5NaU-�.mNء�(N5)	� ��')�=���n�)*�~*��f�S�����lq�{��%a�y��?�)�\7G|����il��>������x:��C���83��ř����m��Q�Z���F�2�]f+�	*��b�m&>$	g�����E�&0�������M�Ĳc�I����	*J?cm3�� IpD��@ްw�y�ե�W+|gJp~�r�E���	*V~*��f��A��>�䳪]ifw��o�J,f�J�m��[�m�(S[N�g:Eş�T�����$�}�_��d���$���o0�<b�[+���ï�2�T�����6=>H��$�qf�K�i9G��e��
|�N NK��6e��IT0?�ڦ�!�}�
w�	FP�R8�{�L���θ���ߍY)��uF*�S��T��M��AHx�ȓ�
�8(�u�� ��������x�7�V����TT^*���&�� $��n�Uѐ�k^��3��X����'���Ͳ�V�n�	*��O�X�$>���A(V���D������r�����O�P�$�n�;6AE��b�m�B�� �ϸfg���Ľ��x�.� � i?�x1�zc�k?cm��|�ad�)�v;�-S�+���W��*�3-�p�
T�Qۜ��/~*��&�� $��KQ��pϱmR���q�N��͕+��v�)�aq���O�X�$>��A��zV��������=�y�8AM�|u�VE�A-��	*?cm��|��K8Y�\�ٚs�n$���w�Ҟ��Jn�2E��O�X�$>��A���_��.V��u��]P��v�e�T0AE�b�m�B�� R��UQ'N�͉�n��Bez�L*Xk��3V�#u�L'�����km�バ�>H��'N8��YvX��ii�數5��[�2�8�bc��GE6��6=>H��|!�܋A����%�l�W�;3�o�4ˁ9�4q���O�X�L}>H�)P����n!.��N�0Kt��L��g���\�l�����[?cm3�� ipD�Ac�s:fs����g�6A�bU����*5���XST|�b�m�>$�́��r�ʣ�"p��ݼ�P�4i��"��XTl�T����烤�}�KR�e_��n㦥��t�1����=čT��5f��7?cm3�� iph8*�1�!F��)�̾8�3���^�Y��e�{�)*��S1�6S���A���I5Ng��	kUlz�"�؉S@���a��	�n&���O�X�L}>H���  �oS�T���`�3nv���8)��NQ��S1�6S���A�Q��o8���(�������1�K*�c�8�}�4�7� *  �������|�4��H~�i%�B��ƩX"?��J����P�5��)�Ek�����d�m�>$�0����k�k�������=�=e��L��3i�؋5A��Sq�mz|�4�";VEi�m��ڽ>��;�P���Yo�{ܓ��OE��Z��� Yp�k�)S�/��V�]��f���w�
�#6�a�y�3A��b�mf>$�pҜ ��L`�Y������̥Z]�}�85M�m��8A��S1�63���A*�;iV{��E�n�8��������M��T����?��k���ɂ� ��3Fך�������BT���J E&�,�j�DBN��O�O~*��f��A��>7��e�(�s7V�IK|%t�N�:.�V�V��TLP�w?cm3�� Yp*�9o�qR��Ma�'���NFd�ǩ�'LP񳟊����|�,��B_Ѯ�Xo�&s٦Ʃ&���^aX�P��t�+����O�X��|>H�Qbw���*!q�{},E}r�V�,a��%�:��8�b��_�T�����|�,���0#3��T��D�,uݼ+*��e���1^�=�T�T�����d�}�T�bEE��0���d{�d߶�
����ⓟ�����|�,������Q�gU7Y߃0�;p���G�W�qk���T\k�$�0ќ�4�c��wl��f���v�L=S�RW�������km��̃� �`���(Z��p�L�uz���<*��N�Y7M��>'?cms��A��}<0Ir{Pz7���y�VEy�=B�����}�+&�8��k�s�2�08���܉�����6g� u
Gy��d�C�ۜ����k�s�2��ǩ�] ��U�&�^�|�-n��%�E}s�L/�2A��O��f�?�[*��Ch'�*��I8L�q�'8��_v��D���[��>�)*?��TܸA܇�*|ຶ�K�	�n^n�3n�QN��-z��4�w��LPA�T��+*n�X��+S:��e)�*��Ѓ�#E�[����Q�w�D*�S���H���Ŋ�*'�K�:sq�^�y�^��u�\]���U��3ڸ�r���O��▊u�:V���F15�4�s��[��n��r�2���x�d��8Co��������۱�!���Z�A�e��yynZZ��<�p6/͡*�=������T<���FT<�T�.B�>.���z%����s*��X��X[�S�g������$�~*��T�bEpK/ΕX�q�'�'�����7HE;�4z �/X��6Aœ���+*n�X���
�۪mR��'�
�{������SQ�B�
yE�u3Eų���k*|�"x7o��+�,'%� �t��jܓnY�����NS)�7u|2A���T��͇�ݼ��;���1S�Т9�g*m��>Si%ίH9���8�f��o�T��͇�ݼ�C�n^�=f��i%r�_1s=��6!�l��3��9N5i�mާ�M�X�|�� �}&j+�ʸiiZN���l!��loʎ_5�ы]7T���k�>�!�bk� ��ۃj�#n�Ĺ��M:�H֫^����e��I���~*����y��m�0�Y�N:��3�+����X`��e"���bg�LPA�T���������I�j���2�3m�u��H��Rs��*�k�	*r?�ڦ�y�8�.p�T�����DmSt��8��e�(�A-r�h}�	*�~*��M���)�э�n��l��oءw�gp��_���N�:R1AE�b�m>�|���>�·a�Y�{�ĺ�� �����m�k�P���otU[�	HT��O�X�|�� ��}.v	��I�+4�n�)7�)����qS6xQ��	*J?cm���<�A�x�J4g�&�:��&ED��MX��I���1VLP��S1�6}>�cpD��HS�Q�d��n
+]�^��I�.�=v��"�xOQ�g/����A�� �.L�tS�<u��ifns%j�dm*��z/M��;Eū�������A�� ��2j�ۂj��]��p�?m��d�	�C�Tܧ�����������@�E         =   x�3���KU(�W��K�2�qr�*��9�K�K�s�L8݋�K�L9S��SS�b���� &      �      x��iWI�6������$sF��s�H�]��m.7�g�^9�� �_#��֐�Ll�ݔ]`�A(����z��"��z�\�$E�Qal� ��\C� ����Z��� p�C �+�N� ����Կά,yU:VS���v����^��}�'~x^į!�O��3���+W�y�Y���������Xl±�{�BZ���?�Xt�X��c��c��c�_q,v�X2��iQ�Q�0�6�o�U�ɉzR*� �k��d�[z��;��:*�W�y�ɯ�z�$�S�yY�Ŏz�/�]�Yy��B�<rb�$��v�bybp۝��:����ۯ|  ��WinBQ�o�H,�N3f����b�k������@�((k.�����|��F��Y�ƺ5J/X�����8�S�'ZX���Y�q�ԯ!~��L��=N��1|�m���I�a��fu�T� ���0���&��S3u3&L=?��k2����I� {��{ ��Х���:i��7��[�����������A�yP��y�Y�Q��a�B��w3������]��8vЯ<��W'�'ܜd�h�
4'pFQ�*���1ts�9b����`]�+����/�����G�5��r�o������)Y;��������Aak�,Yk�&�"u�7�F�L���D �n	f�GV�{q�Z~��)ϊ�;����b@��FPq��Nʺ	�u��h�鎂"�}C�$�(�G5,ҹ%o+`!��yn�@8$��[S���;�w��Q�Y�딫��z��Zgkm��SXG�F��g���$��!Jh%��PB�J�Ykad�4$N�Dqm������J��=��C�(u�Qk����NO}�Z�Nk��ּ�zʝ����L�t�7Iy�&�kt(�ѐ�F�Q^�I���N␝�;���N��k'�$(�W0���
ff���xj�f��K���dW����܋m�7�/��.��������A�tLX��V��'N�e�f�k%-&�� ��i�^��(�Al���� �>�m=n�-�e�Ax�i\߳ݪv�3M�Y����fV��m��/T?���J(��>A �B��V� X��fNȶp�	݇C�s�����Uٮ繦Y�nu���q���r�1�՚�JHW�Dg��/:�~u����uB�__	O�~�#�K��&���@C`���8
Е��g&.&q��f%K,��z�W� x���aJx�tR�y�|rb�t� :����V����$t����P|&���t"�B�>(���m''6�q\$�73�o<����#"��1��
��G@�#�-<Wsܻǁr<P:O��0�ac�y��"�yLM=$淣�=i�M�b��+���շ��\[_=���C-7�+�Y5�C�G���М��z�0+�KH�Ӷ$)D��"�*a��$�H<~�BO�k��.y�il�mO	�֖��R0in5�o����(7�*~��b�B�j]������m���p�'�O4�ԾՄs6N�%~�I��x�9�����=?-� |;2��ʐ�3{[�*�h��#�<��o��r��q`���x���	��Ar����I��CH�$�Cr<"8� I'�L�O���'��$H�!$t��!9kR��I��CH�$�C2bou�QH <��{��{�s��O�B�� AO���I��CH�$��C"�$H��y�~���!9n�C�.NJ�<=-���aN�&s(؊y��!Y���k�u�D�``�ғ���]�Y+ob�z��D�ъ:e<��S?x(���a�g��HL�CA�-�"h��r�|�盄ġ|C�L���$pO-�N�FL��@p���9��g��9����I�@|��C�@�Ӂǜ �ف�2;�0�#�2;�9fv�1�W��)v�MX���R�r�$Xи	^��r�]�H�4ut��i��k�McL����Fg��H��3���б��bJ
�C���b��g�bG3�tA���8L���x��ãP��+�E��c$(���$qxUc�ݖE�V�u��Y=4���B��8�,X~|j�*�Vs��҂M:+y�t�c�!@UL�X�c �����L���2�^s^�Ȃ>'&���W߾_~�VN�'�d!�}Oy�=_����mF;_����]�[�!-ۏ�"���j.��H>_Dl�0�?ծ�u7;�G����Mi�;^Y�A���En�Iu�V�U�e����{O�\� ����@�z��B��2��n�V�|{�^ \]����d���Bou��#����|���_:�}֢������ڹ���?t�?�l�Q>������a�E���&tni��� G�c ��Y�㇭�T8D��?��?(�&��@6���fݞP��D�����Р�2� �Y'�\��pƑ���?��@�����@��������9��cd>[0��bv�9am� ��)p�Xu�枭�6$�W��|�XLd��v	� U�U]Wݟ!GA����W�Ě�;G����t\���"F�cB4$��Y�a�pZ!�
(`��}��AǱY9f�Y�sr\֥��U��k�o��e$�&T����&��B��A�FQ���������5I���gA�njwй�n��j-ikS���%��H^M�������Ʌ(E!I�HxFJw�aCذ1l,�k�A1�R�[5���D�w���k�q�de�mk(͹D�z�W�7 
Eb���S��llm������+z@I7
�5�
?f�5�����ѳ<��g�%��g��f�>��0h�:KM�)eFr�BE�ݪ@�6�:�l��΋���}_�}�,�&�uV��ɥLRdZ�Y���>Rʌa�E��V���O]H|:���J��I�L?��O4'�=��{\���蟊wq�:C���Γ�"��ԫr?�>6��FC�Tl��N�[+�6��1�(�BY�]8&��TH�9�2C�=��盁�}���؄�t�0�6N�8l��l�c0�m�V�hCkWj�T�Y ������2�kĚ���e�Z5k--���2�aQV��%5�2����E�4c�}\���X���b����ZCs�G��H��k~�qa��z���P��U�c�	[���~�����'$��J���Ԣ|Ru)T-�T�AxL�دr	b�B��,I̪k.��aC<�����~�����)��P��毣i�^��P���>�x/Tq��v�8�����1���☊�,�G�UM�c��8��c���$G{k$Vx
V�U�a��{�sĊS������kr�L�xQ�&����6��-�iGk���[���?R\Yy������vDN��+�7H^~8Z�;9M'&���kGu��R#@���;P�^ǡ#�8�4�ԹO��=����T�����#�^�c[�7 -E��Y�����hG�ӣ*{��e�\��I�����"wR`����3A�
I�0����n����ӏ�t��c��b�z�m s�Q�S�w|�6�?#t۰�|i��~#?O陰��&�֚�+��6l�EG����9'6���*җGȬ]
�ԑ�)��K˥�;�:��;p_�~G��ؚuW��o?N�-`T���^S�%���I-/�+��b�ۓ�C�٪����5u�e�q��%Zf�m�JFܡ�sCxƎ�sw�<�h��AÃ�7Y+M��+�����w~����ݺ���Nei�Վha3Rd�wޣn�����Fi)��@�G�҂*�(�%��H�u��cB��u�dӣ���}thl�26ͩ�ҵO>��j4�Xm4#̦�f��Ùd�XѮ�۱��2�4Q�?u���i�5L���E��S^�QE^L�'�Wkv�m4/q���q_l�`=���3�� a�P�ߞ����7s��T(�	��mކ�[:L��:++fd�0�l��	v��h�iMk�%�i�L��pR�}:|�	���.�D�z���u��#_oM���vp&�mF��m��p�hNԶZӎ�Iw���W��Ѭ�2m�ѝ�pc�BN�d����9Ϩ�Mہ����ʶi6ki���Z�R���_��9����M������    ����O;���]�?E�����D��;�S*V���ḁme�~���uD�y#^��������"���A�X�0FI�ʈ=�R�_n6�.�՗w�����j��ܺ{��2����o��6��x^�W�O�3,�o��������a�rF�'=V*�/s:'��4���K����%����Qԫ�V�ry8_BVڦnp���7�Lv	S�_)?x���+-27�f��n����>�=�U�R�yX{�~�Ɖ����ei��ˋ-?�(Q���u��^��S6Jzb]�Mme�mL*��J�~��1�X��h�*5��W �*}�����y�oP,�S��y��|{��de���Y���H#�>����8�{H���w��Bp��(�^�mh�)�c�0�5(=G��&@U�f�M������T�'�4|�	P�*�3��Lp /iZ�uP����aD�	�͗W���n�N��L_�F�U���F=@����N �u@);����^kn�-K���f�a<v	��v؆��S�J=Cs�|���h�b����#N@J�,b�3��%���_XU�$7�Ħ���_��F��vSK܉v1��>3�#���<�.&]�����p�����B8���8i�P[����8:� �tV^m�X�5���	ڍ�4��JR9�7T����&MAe
J�ë-ױ��L� �Sawkܪ��VB{Y������x]5f�X�����B3Z�ՌjR5y���
��̓RH��W44,k�ǞU-�Z�s���ˢ]�d!��Ԝ"�L�Ӛuiu�8�'zN<|�	"�w<E&�>�)<�S�����d7"tV�+2�y�X�"kx���č(d��f��ٞ��5�%L6<�ֵ�6N��rm�-	��ܿ�p��Nʽ��}dg��Mnٖ��Ǻ���>NV�h�ȶ���)^��ɵ�hs-��S�%5|�q�P�2�"�F�SZ�N��:��0uL#0�a4v	�c��^M٘�Im��3��J����'`0|�	PA5�AE�^�R���������$�X�����ph� ���]⒒5�'PiPhI�25ϙA��"U��s	�:�	���#L##���8L�&<~�0�����q2j\�[T閑�kL2�d���'���d�;���TH�,%H�.���R�'���f!��8���b0��8J%�%PG�؁2��W�FQ�^�y^Q��T�N?�q`��������.��Y����鯱�	eE�>!=|�	�����c���-���=����ь-�$��͓�N�G�QW��7���0d^I,O>�Uf�!�� � ���8B>^�'a��wOx�s*>��|����o�E}s����o���_�j����|D*����b}��F�2�����N15�Hf�K0K>r�\�{M�������l>[�rA�����v�r�
h���&�IT��R:d��=Y�+\%L���J]-Z�e�UL2c:�E���a�	�uKe��L��"��(��sZ��Ɓ��	�ob��Ѣ�Z�v���r�JR�-��o�Peҽ9Z�ĺ��R��8����O,[,��d�!�%L�y�SyS�(׉v�av��v{޴�NpQW	�K}�j�q�۱�]_�����૷����?��E���.�_�V��ۙ�G���߯�?��^}��u�^���s^]~�t��:6���mu�{�'�ŕ�8L�pyu�Z�o��o�j=�4�[o����VJe�������1��9V �H���q���ڑwR���jK�s���w�|���	��jn�W�ֿMwOJ�a�WW�U�2g��p�T/���K��c"���v�������%xv!�$�r][_�lt�f��f�뛥2/0|�w	�(�5��o�TŖ�F+r�EգjL`�:|�	���1�
)]�Q��m`�I�gAy�*��r�k����g�K��_�ڀ�Bmkya����SnW�pi.�~l?�R�]����ɽ0-[�V	O<j�4 )�Zv��c�>�W�#A#�i�X�ڦ�S�݌L�S��B1|��}�]S?N���v�c�������t���S[��w�[�^�����6�t�:�4�8�s���-�>�ۦ��Z�ՠ���JS%�rYV�fd|��.ۺ7��[|��e[��)��<�1ښ�V�w��&��s�7�����Gk�0�FqGncr
��8eU�+��b�V[{�{�?o�*��˶�ĊV�q7���,r��-h��" ������8��(h�d�.(M������{�Uj&���]iV�y�mK7��ĞJ���M�����t�M�_{��n┵wO�&�cM�
'6'p��=G�F: ���IQB�Q�zl��Ha��d�~�v�bz2��$V^��$7�}�m��w���'�?|�	K��Q�4������r�}pq�Q�7�r�_R�,�؋�WY#?��>Y�|ǳ*Z��������#{�#�W>=�c�2B�%A:;��]̩��/0�KG�"���R�|˔���Mi5�������V�ǚ�J)a�rD��JWQ��0*\'�U�.az�C���W��5E�;�V�Q�������s>�N;�!�����+6m�?��Af�$bcMg7Q3[�|�X�����Տ�B��|6&60�����f:��R�@����#8���E��)����ԇ�QB�7O�<ĭnV�[�D�p��Hj�~��ٔ&!c��R�jU1����.B�π�1!�������� ��M���N2�Z�6s�i5|�m�#"�~�˿Sz+S?՜��j�=Z~��J�p>a?*]ܟF��u=r}�r��n�Dgf���oF'�lw�E~�F�)?���ժ��ĉ4s�(��u>i?:*��p�zb���_B"j�a��ǋG'SL�a;�u��Z�5�686k��+g�������R�l�؋FQ��0IH�V����ۄGȘԏ�Д���'U�u�y�*��jT���#i�O�o�(�/��44r�gN�D���u\�վ)2�K{ܝ2�
�W)yǔ�׏�)E�Rnk�:K5�	��Y%}{7�<�*a���^d�)vH[	\�6i��2;w�����~08a?�c���r=�=��l�B��3K�8�_�J����\4���p +-eҸĬ7'1���oH�a�/��]\�|bXJ�ּ�XiA4>F�~rQ��I?7P��8�Ҁ�]�� ���ȵݸ}�BXC�w��a��B��L)��)���&���͊�/�;|�ѫ��.}G��IV������U����̇����#b�"fD�A�+�Yyĳ����F����a69)�o�u��c���#���u-m�׾�6z���R�����|�q#]�z��*��a����/�?��Џ��,V���>�R���s�囤V��kG��Q���	w�<�3�3
����m3��E�c��Ob:�eF�T�S��"Xi�]^k��h�®�c������"�_E:�U����PM��= Ѱ-�Mx�â��P�p	�R�$�,�|.����3��"��o��L �q1�0x:��χ��[���x�X)e�U�#�+���"q{����rn���?��Gz�������9??���CvIgH\.'�c�X0c�Ņ�lK>tn�k�Ie��N�{�Q[�[�)���qRӋZ_�o�w�"��/C3�Q�bW@���C�N�Gā��%h�\0TS�:�V�������o1�"�b)7�L�Mm3��A�iUvlWO6=���9��鄧4�ʰ�R�B�s"�e��m5x�C�菊�j^�$��l�8U��<2��"���'�E�[�|B/�+��J��*�lY�[6�������U�ð��5�I�,��*�,�j52`x�>W}��}���)�	�ah�!����G[�Q���{����#�{հ5ȋ'"���a��׉���C����O����:"�ן�7�M}�Y��� ,�7���nBK*��F:w��/����,L�w X��S��9X�)��j���~��I]��蜐�X�����3F�/�[�R%S☄n���91*��u�d�Ǫm�x��� 1�3�|��_fl�Ir3H�����=�G�    Pn�?ҩ4��c�"���	$~Í<�q�[0�{����Q�T��)���ъv�k{�H1D�$r��'7y�b���Q���<b�|��m/�qm�Ei9>a��d������H�"�Py�Ѥ��wm��eYhu5Z��G=���
pv��6�H+uv9�f����U��p'���} �vG�%�^�O��덶��*�t&-G�o�P�Ǝn�U<�mn
�;1��,��q�<s�Ym��gX�W�#�5����=�w��YE���U���L�]��ix>�!�P�m�|�$F��1)#3s[_TYY��V#��& ��N]���v^9�D����t�j�5�諮�F�� g��V<�O���k���L>�� ��)H�Hs�n`TN�i��q��\�"�/v8u�*�#�[����,�,/���h��[�7�m��vc�ʠ�M����<т5ȤF�x�wt�����֍�x��	�i�im��������ۣ������=���򭡿_cR��:�7��g����6�7�:�����L�=&��U�Ӏ��"�E�g9�J����h�*n��2_Z�^0��?�Bi�5k-�)��ڷ~v��=7�n�p���R��iY
ߡ04�
�`?��W��&�2�i��μ�}�Q�g��Z��z�/��_Zx�3�P�>���u�n�ub�W��� v&-��q��M,��pm`�Zf^�q�r?9ܚ-EgK����SF�tTi�k����JKK��ܻIu4����`���J%R�$��!Rb)�<�:��T!ŧ ����I�H��!R����[����LXC�=9�c���+I.���D̫B��N1�<?�A)_�|~�mé�=��t5���.�|�o�O�ҖWoo�������M�a�)��x���Z�~R�rj΀H3�o��Ԝ�	��� ����9 3�/!!����%;'�-�[��n�7*�U9/j���ۼd�2��u]O�N6Z�+m�[���@���c�U�T��</<R!#s���[��p��+m����CX{ٺ�{�z���J+]��V��
�?](հy�����G�P��O�V�?��[3�S#��Dw~ؕm�T<��6�d����I�{�з�'H�Q��m;�U:UԢR�%���-�q�_w��K7D���U����)^�P��3��]�yB#/�y�%<�
����)�A��8!@��[���f����A�Ve�Ԋ����D��H���բ�y��<jq"�]r<x�	5�b�]C�Ӎ�c��++H1C�./�M�O����V�Q�T��-�K<�F��+!�_��j�"(����vZ��c���~��~��ЉK���M�}sk&<��2���v*���\��N��5k��&�f���~�u���]`��B���H�!��3E�7*��S�R�0��Ԍ^��	�)vlֱʚwI����c�i�ni;���e-����z�F����{�R����,�ӌ��j�7>�L(�_	Cq&�����ָ���S�^0*��QXQ���_2:+i�����h�P5c�n+<�{Dt֫�N����uT{��:f�u\e4��Y���.�6
�M&�ץ���Џ�g�ð�>J��G%k�#��@�����H	�M��0�P !	�����N�� ���c���]k�` ��� n+������s�z���NR��q\-�����'H�1�X�q�,+b�,P��tׄ�P_;�V}����K�,Hl׻�[��k����ô��ڍ����r'fg��"�m�s��<��aбJ�Ϣ���M��P��r��1`�e�iq�v�kf`DZVMg$�`�������.��<�+*�8�0�D�?�� Qe�ڦ.r�.�u�� ;I'�"dL�����
!�cYN,;@�+�H�*�<���Ϗp�I���}Y��N�æ�'�x{�,��RU
o��?\��ܐ�ױs���y�?���+�×?���v��g����c��^���hV���%C*��Lu���g��_̰�:�2��D�Hׇy�ۇ��CX_��@X���!�*'h�	[�lE�kY����(�?�����e�|z[_N��TS%�`(��N��^R����$h��/���Y�Rp�(��t��Ct�S��6�K��7p3�]s��;L��Z5���7�)�+����$�LoR�������=����kɔ	�ZV�+�����B�K�gO(�c뜝Rs]�Պt�5���r7g���f�y�����n�I�ʰN��3�@����&�~V���:�����t4}iN�2�IS��;�*��f�&-�$R]^�/r3|�	$��w%?E��XIU�|+E]���moz>\N�_"տ��U�uħ��_�e����cQ���5H(�Ȏ�&VP铠P�!��7?���
*>	*r�j���h8�!���y�tN�������K�EA�N�R�ԅu�s�F�ّ�V��z���r����=3L�#,�k3t^��՜���4K��c��퍠z�ά�}�)V��mZ#��r/`4E%�S����M�:/�ƒ���;�����5Ar�|�v��.��7�{�1�$�@����=S�Y<�)�q��!Rx)�L�:�@UWH��e5/yfm� �P�+���M��'4e?:��ֹVx��%k�Qw���c[��n��ne�VZ~���| 6tG��^�A�,�9:6��*�Om��S#���r��_Sz��P��Icc$��dK��/%)����L�u�!_z$�kz����o3�!��n�kҒ75�Ir=�].��{,��3O�`��ѻa�� �m7K⧖�6i����ѯ!��W�;%	#�F��Խ�m�jY��4�;V涝��o >�d,c�5`i�}K�k��9����Qs�m�~�jl���E�o���$��vr���\�L�x����]{A��s��M�$���Ç؇?7�9�TI��$��!Db"�� :ZW�X׃���n@�,,j���exu�`��J��1f�vúLϟR��|-5kW˲���?c?B���/�3x�	����-�<�+/�F��YT3�Y�c��oI�"Lw�eW�F����f�"d�VOg�$ֻ����4�Gdc��N��Mk�h�X�����=�à*�"Y��eNw�ԑ��r.@1>���,�`b�xh}�Pc�"L,��0�0�F��#F*�����6�/0Q{�)�涪�K��Cu������:��G7�ګ�}����6�#��,�r����ެo/ X����u�������B?Y���v�|R�Gg�
B;.��m�4�a ��	zߓ�!��clɠ��nx^T�[������g�(��v,���{o�[^{Xm���vY��6�%��_.��Ыo�;�a��1|�e	�7NNyz����Nn��BZm>��?,��B�	'l6�P�D|���-A�x��� ���4��2M���h��&<b����ϔ�ލkie�T�]9���[W�V��O�;��'Q�͏ ��#�k�	����#�|��#�HH%���H`�X�іҾ"�h��h�����do_p���/i�+�L3��ג�Xq+LD;-yOz~���D�Kwu�E	�[�ӈ��,���%CE�dB��x��Ru'.���iɝ�k�fd��}���M��zb����Z�	Z�5���i:[�7���64x��V1Ұ�'�zJ��iVQ���7��: At�����sv�Q�(�!��3Di���W^6�KB}�i��R����2h��K:x��J�滑
�b�p���
���y�p���)�揰�Y%�vOx^�{��0�P�0u�* y�м��ԵOLĔ옢=�D�	��Dv��C�q���ȃԐ�kѝ�����Ԅ`pF��w�{�]}��Oj�����$W�)��C�!�
�XB>G^��k�~�sRF�1��U��C���1����z;��n6�j~�?�o��5 �ߑ��~|5��N�o�r����J��wO�N���7��aѓ-��Xe>�����9���]���s���L���зB�]W>�����Z���Ej�u    d7�V���"�ȄB�T����!**-I�J2ˤ$:U�Oət�G*�:/���0s3�8p�HO]�7��[!J�Ƕ[or�O{�0�8+��Omٮ�;m��f4����-U�z'���'��A�C ��ұ���9��D�Hǲ7�8S"������H�X�5[��>���H�h�cCg�8��'[[�K��Jo�a��<�f\|�������'�$qC8�g��1?I�D��x��������p:^�"��.$]8�m�Am3�W	�c/J��|�m�%��^���4[JP-q'��P���Ѿa�g��O5���@���x�K�kl�U�i�UԲ��?fi�0���8�W��t�S���
4#,m�[�;���g�hLy����8�B��N`��TMվɱ���]�x�8��Y{n���M��h�@��u�v�Nt,�=�=>�k������K2�b,�\K��Uݍb����H�;�����h��i��Aq5V}m��c#��k�W��Bd�G9��H��}��C�e�a�����2�y'O?�2h_��ؾ��j6��~�z������^���6\nn�pF�g���쯆}Tc6GH~����9� /�~�@\ʹ���x�\8�[�G�>��Ń2�27k,XM�8~��V��հ��հk�#/�)������u�k~0����]���ՔrL�ĔE��D�*�jֆ'� WuI�*t�zÆ�6���*�Meiwej�;R��Y�*_���>}n��'X�T��tL�m�eM��Y$�eL�:�­�sl��W�z�a�ӯ��S��)Ҭ�l#G��lb?Ngn����}K�8L�&4z�0�4xumK�0�C��L�9�t���1Us ]d8��6��L�ڰ�Dh�]:	���:X�E� �4~J\hAzw�5ɤVd�mR��
�[���ĵ�F��,�|�8>J]��j�����u�a����ΩMd�M5�OWZS���uU *�/ݵ��3�Ī�	1z��t4l�p�'�q�C8�g�ӱp��tpҥ㇗�]:��.���(��T ᠉�Y�e^&�(��M���j�+�v	#z���VS%V�E{��g��[���͏�.��܈�6A�&�S䶨i�oB��=�ˌF��{�q�x���H�s�į�7,P�x삡IL^01t���`�T��"2���!�!.�ϋ��f%@t@���.[�g>ڴ#E����W���я�7�Y���������������ڝ���������*���l���^_�w�|���������?���:2G?_�>�����u�>�O9A��l���t5��E�9����v����շ�ٛ����r��`���9��Ѿ�L��v~{���CX��4 u�&��I[�'���]�H ��X���L�.>Ӹ�e���d3�2L,D9ɰ�aq���)��f6�E\uO� d^�t*�DG�,�#�ÌQ�?����#�|ja������ƻ[�g�r~]��lמ�c�����p�Z~��?|Y�����g���M�� ��𱰸�L�8 _.��b�����LP����oI�4�z������}y���z_�8ı4���� ���D����XW�׉��*1p�5���bػ�J��u���Wɲ=�΋V+�����gV�DqN�g����s����o��2��	�>�qY����x_<�7�z���XTO��[�9��߯e���ҙoP]�a���s�a���,�<VQ�3����WUf���#��_�������z;��i/?�f�;��j���׺�峿ǡ6�:'��}��fe�����3��~�ڇ�̿H�O�=��?��k[_�ϋ����[��Jؙ3���?��Q��2҅�ZN��oT ���:i]~���7H�ߌ8X�.m���{��/7w��8�}�������ZZ��2�b�|PmС�,�����sum����"�\ƚ+mC�P��8�1�H>�@�m�G�����C\�wE嶀�R���[@��/Ђ^2�/�#-0ꌠ�}����9��^����tO��C}�,?�Y��pu�˂�r2-� :)�������?e5��\���
,�ޯ���w�+���N]��&�Ї������R^��y�A���j�[t�,�Ur,��ӚR0�I��L>��;��;�%�cN�@� � �sA�R0��3"?0zq�϶T�q���ߚO�Xe�!�E_T֋��)*K<����ް��a�0̭\�s\Q�j�[�#�(���J~�ǯ2?�Rh_z��l���F��w�%������B����;�'	��Nk�x*�W�`C���<n��,_� T���uPJ��xT)��8�C�t��"����m���ZnU�4|�:�,����m��9)�{%ׇytw�|��R��	g���Rrm�C��7��-�ɿ��$7�m����<m��"\UB�����d-�9bp.��d��K1;��g����^���g��-m�~\�o.>&�X��K�	/��E��^��t�������-z���/���н�_��˽�	���5�O��J+\e����*�8M)(������j�F�4AEm��u.�(��ѩg>Xw�:�J��Gڮ�M���~�=hq��]���V�DY�[Գs�--+������a���w��>L�d�@������MulQM �p������P�dz2�11<?`^��P=�X%�|_�jz��U�&�`�0X>�ǳ"|5]���}VLO���*p'��D��?E7׋���s}�����0BjZ�2yW/�˻���j�]����x._㐺ZLhO2k�$e��sD�K�CR�@~	($s��\R���9DP�[�;=	�G�d�<S-�@�1?�}����8)�aL� tl?�V2�OY&�S�|!��������7.m�3r߯�+�v�Q2�W/�g�V���7����ji��݄݅ W�>�Kp�n�t��蒾�JS/E���q�}&�3F�t�Yq!0ҙ|rB���Ŗ@~�В�����ۧ�	/n���� �d� ,@ׂAhGz��E�䨮'˘m�)�sJz�T�	#��#�˵O=�j]5�Q�6����v�*HЙ���G�c����������t��$�Jx�n/�����'#ݤW�O2Y�̄��@�)�4z�d�����"�FXz�����5��[���{�� Ƣ;�{�'_ss��^}��o?�˷7w~W;<�l��򮖆�f��e���*~>��WJ�s��VWLe}�/�0F�{������R>�|� �/��98�_R���~���Ae]�k�J�Ez�_|%����uz��VE=��������]8�o������Jx��/��'��'dj�{�m[�v�>�m���m�ܛ���{�roOo1z2��`HU�R�jߌYRǭ]���*Nq(����C+���~��Yy�S�^]yf5�M~T ��-MW�kڨ^ }qF��:*&�%�Ch��<6]\5�id�0K�		��i��Y�(	�vk��~����10:�	k'��(q�lu��y��PH�R�ma`
����p�A/���)��O����kԑ�7�~XX��:~�Y�<�a��<2�'bG��9"W5�]Q訡'>�ā�NQ�-?d1$�!��7��%<ju�?�������<�W�Y}��f��H�_>��2X_]��aHS"����W���F�ڸ���HM�D�^��b,b7B��B���~I��s� ���_,Rq:��"۪���S�g%�Y!˨	����X2ю�Z�С�| ��ޔ���mihm�n�������T]��@t�OՕ �	 u������y�4�UX�+3
� �~7A�xh�!��=�}0�02� �:%�/h��U��֤U��*�ZUhv�LT.��R��}��P�(��'1:d4�<��1��m��_���#}'�_��oĹ'�2^?!���j1!?>���7��h���m#�=��޾����[��ȏ����I�����{ˇ�-��/��g�[���৙����s��YA��D��\�^��,tl��v����:Bs�Y�ۙڎ�l�,ߏT��ڲG�}����������V    ���2T�*y%�n<o��o�6�J��3�z{�<�H�g�����瀑�H���B@���uB�������f��o�����w�"�3~��C*K�����ST��dT��u�n��plS۬A�.��y�a&�h y� ��ey���*7�$�B�����/��WD#�/���,���ܜ�Z�����	/��E��^����D+�&&H���жd���l��d���#�~�A��ez��b�6T�_�_$�O�l���,%�&I6t(��S�ۄg%َ�FU��͹��^ۿX�����'�H���$��=���]����ʣ"��#�ʬV.W����*����[b��磈;dQZvA��~3سC偀�|��R^��MDo�V���*�R�r�r��]P��gz5���|�^n>=ÑQj�:����bA�X �c�9��P�n�����\�(d�b���;As��n�Xe�O�&V!����uj��ɓQY�W�둙ee�F�8ASM+�����mP G㤻��mii�'�Ƌj�9w�Z��j�5�� ������.�����H�D=�]�s��X[���'h�k�������TX�H��"��ө�P�Om�P��G\v	�I���c''�'�E��/mCE���E����t*T,�4�!�OtR��)f�A�@���d*&c5�8�~@/"�{Ce�ZA��X*fCO���*���2\���jnw��e���qx�,�e�y}��U-�W��>�X�g���|��q�Cc�.�~>�`1#Sr!�D�x1gl;���N7�m��ת,4T�^J>^T��PY:xZ��nr�Gi�e�s<�S (��@����6���1���<��ָa�5;u,ͨ�Z��Bg���b�$��!D��<'�Fb1�ǻ�n�l��b�?4&���|��?G�?�nW%��$цEm义�c�2�h�����u��/mC�D��$���SD�SZ/��	6�V������/w������G};��	[�ȅۺ���S��*��׳4�_���~�?�MgQ��#o���7�3�K?��`�<(7~�R���Q���3:��Vg^��{��FY�A}�[&?�F����n����^J��)�um>��y��A��&�o�8��J���_0__��pEt�?h#�@��!��&E6c{���\�}��aI�#��/�B�J��.�1IrN�~N.9�t�����@q�)E�ₓٷ��8���c��z�WTWm��3]>?sª��L'�/�B���'_G���2'�/z�IxQ��R�[t�E��܏o���j��݄����U|s�_}�L���g���kT�)�'��e�RF�.'�Q]DϹ�X�;e
��#.(!�g[�/�	�R��u��JTR���}Q��&J�R��V�R���q���~�$��rz$��E��H�}I� cubI����&ej��01���R�J����2�l'��?��+a�N��C?h���	^��Z�Y�ބ(d�Zi8�f�i��U����g�J�y��Ϩ_|�!�_����7�?��9�!9P�V\�r<7�]���6���~�j��a�瞠O��X�k7h^�M�v'��*��M�Zh��KЯ!R�D?C�'�3|��u	R������}헮|H����"]�=�돌��	���,^�r�� �D����nl���ADU�Z�Hy����bń�0ۀ�x�V~+��&O����o�͵���c}���k��&y=W�/�zy�k��;�=�X1�g �@�x�fh&����>��X���2s0G������@[J��x?w�e�U��z��=�E��(�}%J`��OP�'�	-�_8������N�J��xQ��rƤR6�e1���"Ͱ�À+e��9�fB���+y�	�t^�����;5�,y=����\G�2��r�[r��Ux���1�[��^Ft�/u��)Q!����hqA�9:'R��svq.��LhJI���ʅC3�I�YL3�u�!P����K(J����4��S��ʫK��'��wm�厕h�yl����v���3�g�|m�#w	�Gq������+H�'��d�dG��8r���r�d�e��Ӫ,}ԉ��Zúd��i��+�� k3�s2XY��SG7ҍ�`
��r�ǉ�l���J˴5�ߗ%��
Ѽ쌲�2��<���s��c����z|����'�� z5����f�W�mr3�� ���;������|Q/糋�׳Յס6wL��~� ����U����BJ�.����閁ul����2W����/�������̸[ݳ�Yض��/�)�U�
�_��x����YS�Y�PI��[x�\Ik�f3�S��7גW�,�j��rc�����v~�\�<�0�[*�na6S�C�bqwKi}c�?�**����0�4.�gAZ�g��d8y�M�ӳ*���}�D�fN���1�f+�Bu��p�U3|�<�����j�\�S^Mr���zײ<�&֟;'�߲�a} �X�/�忾eɞP\����r�$h��m��"I^$ɿ�$����'�$X@�b����p���,�mO ������C߽���w��vr|�_�e-?ȿ'��n���f��ksJ\P%��t���RhR�)>��H���T���|<lx�A�q�Ӵ�\�~�{m�v���*��lӔ����(��/����yf5���Fd�Q�5��Ƶ�����^�UF������}Y��
�}wc6(�o�Tݒsk�D��r3��{����CW��?�5Ϗ,B�\�x����1̓/|�/�ρ�:����l�(c�3]l�S<I��Cy*��x��T?��r��m������sD�L�>��&�_�ˍJˬ�Zk�lJH+�J��`��=!=�(�Y?��e��@~���GR��s�|�z<'L<
Y^ Y�cK�IE���'wX�1T�H�|���W�G(�\}�>7 7��{)?��X�^/�o?���2�~����j�o :c�gR�TQJu����Հ: ��� tqA�gҌg�)�d��w�L�i�oͧ_lp�!���\/׿����oU��.Uޤ̈�0�l��� ��Tef�̈v����dﾎ�7m�O��'�Zi�Q��]3�O�k��P��X�a�έ�8�I!3m�2c�a0az [���������t<u�|oJ�Y�ɴU�5#���{��đdm�����7��]Uq�		����q/n����;�@`ï���n�%6�{�=;�v�VIV�Y�W&�l� mjT۞A���j�����|9_���/?�l�}Z���Y,�`��i��T���0
�0N�$��Ir��j�٬¨3ͲC#�D��"J {����6_���߹����^��1���������w@�y_��]����8�2�Y��v5���m��Ѡ����y��#/)|�8be}Ϝ���imM��h��1�g�є�x?9�}��o���J�+�a%.�JpVV��<�N������X	��a%>���[	v>Vq�p)��E�SH�[.D(�OĪi"bľ/5�C5#N~�3��|��p�B�6�h=-�}���p�Џ�&��]�J=Ul��l�� �ԫ~&ׯ��~�oM�7�_p!B���[/D������.��"]GP*:�Bqsw�iX�u�r_jP�O�Жx��@�'̲i���yZ
֣���}%a���ު3[�N89(�E?AX�l��[��]6L�t7�Z���P��5A�����.:pHΦ6GY�0���G��J�6+�>�ć��|+���t>�g���YCB���3KЄ����[7^B��O��ޫ�]�8�l:��t��=�.��@��MwQH~�'��� ��-�a.z��I�Q�`�	qa�B�Θ��Afj�LqSd�\*����L#��ƈo�m<J���p���p�Gj`�No��o�8�9����"C�	�+N�AkdrS׹��E� *,v15 !F��0��w��P��*шUYYp' A
���2g1K�[��Ǐ����E0����|/��kRު�R�����N�{l)>?�fD�[r����    �>ݥ#����%�*e<qf4[bA�t���d�e�I��1���C�vT�\�t�,��Í#�W�ڰA݊�~<DJ�C�pƮ�kL�q4����/r��b7EM)_O�� ��|_���D⣔��;W2TS����>%i�i%������n��(����dz�}i�MR-����{��Љi�n��z�"�	� �фE�������zE`+��p�I�A��R�u�AF'�q�2i/��^�;�e7��B�[LaE�f����'�ޤr]DH�'���&^���6&���7|���ࢹj�i�\|��K��%�O*k�'-�׷ٍH��h��}Z��V�ҭ:��N3�$�c�	����P���ԏ�s�K��T�[b{�8��x� �-"��1�j	�� wξj�F��v8B��Vu;��8�v�K�h?N�~l$}d��&yƗH��?x%����=5Lc/�:��h5@IWzu0b�ؚ'��<ɢ����6ϖiQ8'	K�z���F5������77L�n,�#3�I�v擉�)J���"�I�"�k�
��y�_����7Â�F��X�.�wL�>5,�h��w�ȐDؕ�BYY�=��>iO�<_�C��y;���t�j�v�b�I���)�+�4C�}ۍm��H��'#���$�ԧZế�����5i�:&\�g��z���[�u�\{��<gD�^�C5�7�=���3���j]��N��3y����yul ��}}������~Zf�(����ʎô?�ǹ�FtG����}�xFt�""m �&ET�8Et&V�_��P�s��oQcC{cK�5Z�v�Q	������~f���c�w �_�����2�z?#�/��x)��x�����#�����ϭ�V*�� ]E�U�S�`Kw�BnD��Ѩ1K��>�K�N=5n���qv�� G'�D����� J��8�.���⤁]򇲩3�:����mg�_��d�u�7Mq�/*G����a��������<k˧���q������r�<��l�ǟ,:Yy�J�k��=�X;H+�K�mZ!.Q+^%�a�Y�ю��G50��	��R3M�������~���m�D�+�7Ǚ��#uw��6A��sbK�_�����S��k�vP���kg�k�K*���:0��a/���D��#ۛq$��2n�^��<�l<B�����ǐ�V�vF���v��&���kR���(�G���GZ������y����@�[j�X��O�y��(H�/��%�Lj&*'�)���������[7#�Z�g����ͣJ����[����z$��v0��qBl�fӏ��vxO�ʒZ�G�+��Q��5`!��365fa��w�t��5h�x�2�fl��я��3j)ß0���W՛T��-e���[K^X����w��4t�� ��f�
X��m3�cS�6�v$�U�5�2���٭�i���������Z���֞-ˤ@���e�'ْ�4�,�|y��q��aw����,��4)��(�"�54�6��}W$My��4 ~F|xK0I+���y�ho��Y��!�T���,��Q���.�ȇ���2�2|�]�(?wF���@�V���� 
�j���\b���B;�C���o�T#)fU�4�u�Ej�����q�7����~�ހK�B���f��~h�/�Bz^g�����p��i!��Zxb�¤�?��jf?V�B��Ⱦ?G�fT�Q?�g#�����/:yʾA��=��qwJG�P�i�a����fd�����$Ou�u�_W|^��G���]�ݯ��,�'}��{Z�z�3s��{���-���c1�|����]K���vG=����릑-׼��_֡�*f{�S���y@�W:5�*-���on��8G��ĒbOQ=�y�����8\�q�d_%��������KE��b��O ��|6��~s��F'?��?b�������`��o��f+A۬��V�?�J�Q&PZ��$��ug���D/4������VB;��4���$��9E	�E�zI!�BrLA=H�J�	��\>O���$�/b���J�%q�"���;/4���>K=_8��^~�?��.���B�	iW4]\PoB ����&Ը&u�C`a��{��L�X]�V�;M��"�=��	�������QݦTƮ�xØ��j7�Q��	#���+̤���]��p�������x8�������Yו��4u	�U�-}3�]i�o�=��+qx@���ί�)�����B#P�4F_o7�H0�)#��K��B���P�BL#[��i>�~3�bm�}`�u������N0�|�?��h�������J|X���M�������L�(%�\ B�"rVa��	~lAM�^��{h��\���4ZV�?�`�Y��8	�I�:�_nf�|2�;�f���a��Qu��aWXk"�o��6�~^��;+��$J�*�@�i-3�T�:�<���`�ĢLK*"�?C@=!�4� Ȱ
n�U����$H��$��!���NV��NT����3ݾѦ�(���,\N����Z� ȗ͟	�T���.))7���<�<d��Y>���#^ʥ}��rQE05w2w`����t͗Ҙ�\i�e������,���*�Ig�<�|q�R.�{l����O�ꑏK�+2N��!�gy)�t��ǳ��,���	+ v�"�A�pO�<(�S���#���>-��������~=���������{յ�F�]�ʇ��kb�㬟}/2�Gڕ�5p��{�f@�C}_ψe�p�:�Bf�.7�I�I{��f91�O�r�k�}ᒲ��"qE;�,��*�����*�������0�+��{�4L���Q���;I��2^�2|�2�7��2�9��ȏہS�,�����vNn=2������ܛ�%��z�0�@����z�����&�C���g2��{�^�����cǝ�M�q����}��6���cH��-K+	}�9a3�YP&�\�|�/
S���>w�u�N���;�Wɵ_��@�Rt�{>@tZ-:5�S��y�ț�#%]�a4���v	=_8"�~��U֙�ۙ.�ǉ�!�n����Jt(�v�;l�]PΝ��͖�b
�v	m/����A�S��c�p�wt�`D-�9x�|�	3�y�Jg������v��A�1�;�/j�(P%i/e��#*}�l�'���pR;u�`.�wt�`�J�s���Șy�?~o��5d���쏴�@ڟ��)���S��!Z�O��"e�T��)̪��\�n%�/��R<��e����ݣ��7d{��|��E��T��V%.'K�v��/�t1O���<h����[�
n�<�;:@0���p/�	�^o哠��Wi�b�к��A0t'��'�XF�I}���o�i4`j��~ihu4@U�&�fsM&«��`�X����|�h��󅓞�cCn�Zwt�`���
��bQ��d>Y��W�s�\8��-a����*������"U�7���"��3��_�ќ�2Ѳ�}��'�Z�e٩��|%:�z��� ��Y�B��u��}Es4��l����z�pD��I�l��O6q;��iة�גj�j8���<@Z�ib*���&�$�e�NHF��;���H�P�/a��Q0�f�!W��I��gU��_�� ��3پ�DU+��o�tҘ�n��4��ī���$�y�p����d�Dҥ ,�]vf�2�8��Q�b�!wغ��U'+���y�i�&3VN����i����2�^8
�x5�Ã��c�)�`�I�VCʫ}����S<�P�,o��,p2w5��2�9i���#L�jI��2��a�Yѱ�5���M +X�JA�̒�"��g�`�͵Y�)p�v�<_8Y�c(�|��������ʹ}+H�B����T���4�F��;#2`�����J��.���c�܎�!��Ӿ�$��||��z���o�w��|��w}���]��G���    �ٷ�l%p���V��J\��䌬f*g7��b�-�U(����˂$[����ë��T#�Y������!Uо��Qc��,&Z�(ex&�X8��J�*�����R��%�}�<���m-���z^��8<��:�p>�8�k!�֘q�?aҜ��[����~1��bmb(����1���$f�c�-�p9w���t��An�1z�pD̫¸Pf��d5ܖ�o–Ek�ᇨ/T��U#�$�D�i0[?UF���$�nA�c�b��6�2��d�8꧛��恘�Q���0W�-1	���|�= �j󏅳o�Gd4�Y�	�#d5����C���T�����q�#�g��l`u{@S��P4�������O��,a�+_�`�|M(0A]f�-k�,͊I��`�*�	\`g���/ڍ��c�^*���<���4Tµo� {�*�ÆJt}�iu�K���ql����*��5���z.��ߢ�Ɔ�Ɩ��h]�tG�x�w2����0��4��#r�u��5�m�au�N\N�d�f~U. *�eL�"o?����R��i���Ƿ�Nް��mp:�+EM壣+=@^N�4�A1�TK���W?��6^�>-��a����̾Z�C�!)ݾ���@u)��P��p�fȳ3_�*Z�.��ǣ�]�űw�賛�0^ն;��c���;��� ��oQ��*�h2gU	ӕ��r2�|2�OP������Q�k���\X�lھ��Qߒ�sxy0E��?����MH�Ӆ��v�����n �Oʩ?i�;d��o�sR_���y]���_TD��1�h�;	����h0�萘�b�O(g�a4���] ���SS���'#V��4�&�IH�ȉ��m�s�q�+��ڹp�뜈�Ҿ�āꔽҍr:�%�,J&�Y�&��[,�g�n� Z�c4�Q���|OҲ�TN�w&�{KV���H|�J�ƶ}���F��:M%��l�f�����1]DY�Hg�m�����0Si]¥���(K����T�Ժ�ԉԓ��P(�9|��"�j(�6O"-��L�����?�}B�j���|����]��������ߪJ�%eV:4]�N�,��3���V	b����l��68�����u�������<��4��<Y��%}&��ҧ�c�x��&S���C˛*eZ7q�,�BHME%�9�����)ӜhUE��lUgѾ�텿�����$r��L�p��#4Mhz���lB���잞纷6�7�W34b7ʦ��*��ߙ'��ѾŃ��s�'�g|.�PQp�9W΋��3�~!a����7Ly��^`�R��F��w�U����}�����ZU_��=�A5��f2�7�� x������m᭩�W��М+EW�)�<4犘��^o_���tA�P��%�XP'�� C]���r�B7�sĢ�ٌR��PF|�I��9��J-�}fBӸ�Ø��09�M̃��Y'��SzGuvS@^8�K���+ñ��Q^i.�b:��n� 0X�.�� �6VK_�㉋(�1K�G�̗�)��j5�:���qa/Ҿ�f��&�%��ܠ$YD� A�l>u�v��|���d�O�zo�&4@��M���$W�m�{t��~V-�+$_@0)[��/��|ᘼ�,~^�|�`C\۾��PGg\�J�d	�U4�J���,	��	�e�vu����C��YLo�S��h��o��~y�:��F�jU�'n5)�R�m%�9,v��Y����������wȢ�Y�uȢNq�m��%Lg��ƈC�d��m�������a�J�`��] ���2%&����)�_-�ʝ-����QÉ�TS�(U4��zq�"1	'w���G�e}�J�.�	Kԇ��Fe��e��E�p�@GD~NN.�$I�8ʣ� IѬ�0+��)�6��=*�:96c���˖~�pifs6���m���Q��>]��=���]>v��|�he/�3a=�W>V�6��LD٣
�	+��*	�ĥhVeaT9'W+E�5BwL��A=p��N��E'��=Xwi�Vծ��W@��C�����8v-�r��v%�^8�S�ﶻ6�H+r�Ny'��i��j�Z��_ZuS-�i�U�N D>�<,�x%�ݫ=_8Δ�fŕ�\/�qDaHn��>��8�*ǵ%�jI��?��
�i5�8���px\_W���y�UP����f�}3Ȅ�t��$�\��0e|s�c�5��Q�����z�(|bF�H����Fa�B5	h���x�׾/��ʓ?���G������#�I�N� j��:9"L�C�	�0
��=*�]SX[\�B�vQ�Z�i@B�ь$��e���b����h��I���`"�G�QiI��}��)EML��[�{b0 �DTk�`ϓb�M�U�XE4�P-H�Ʒ��T�%r�{�&޸�= ���H�.]�E�R\y��Rg:s�b�y!��{"�_-��{��= V��Obg���!�Y�ǑfoH�c��� &^�X�0��A�ݒh���� �8���yR���`���ٗZ���`l���z��<�����^Z��]u;�������c{`�L�kOu��(��01���=i�u�b���)��:�Ж�'z����MWU$-�ey*�L��
���{�诶
"m��V��8�*L��V�B�e�̑/:ƻ�i�{�/M\��M��*�2+�"�#E�/��VEH�A�%����]�W��� �}O��Nr����r +�ؑP&���e��V%OI��/��n7�x���_4O�/B�TJf$�\ϟ�A>_�"ύ=�#��Q�h�5��Aoө��}ߟ��o���!�۾��A�x��u*���c���YN2�~N�?㫭�����#�x�P�{�$yWw ��.��8 ���<��0g�%H,�,�P@C/p�V|Rn�6_ʅ�����
Y�W����Z��4�`S�?q���P����-%����ɩǼ,�_�ȳ��*����,�i�(�~�#��4�_�ۿ{�`;۷s�w�j�$��=��'>)\!��|M�r^l�p���F�#D��h��p��1�}'��	���z�{@�������$����+(��$���uG��4���H�qw6�!��,���m����`׮l-�k�^T�uu�򝼬:Ť:�8;��Z�$ EWZ��[u��~!��BmB'$�*A��DC���a��Ν7�@�����5���!"-��	w1�����Yw�c�F�%/����Gr���{���0�*b����sҏ ��c�σ�q��"���mn�����O@Hg��=���/"��a�c��!]�M���(И�)ٲ���8&�K>�F� �783�Аs�i$4S��(�oq�iq�ʹ����[�}���# k&˺y/V|ëprР�0Xt�`u��P�N��y�W�PR޺� ��if|~ �� 8J�k(B�� ���R�H²��0B�DL��D�n�K��1�Xx�F����26��A��y��Q&f�x�M�|����j�"X1�i|9�<�2&^��E��[na
y�|8�A.�
L4��~��[�3�$�W�%��u^6_��[r��0f�������(NC�|q;���a/S�7���h_�p��m��=�HBhsC���p)҈F�>�3L���"AF��O���F��g�t*�b�)�1[T���'� �:�����拧�����ʙ����.���-���m^��2���+F��X�]�3��IH�4�b������}��p���a�B����d��i`�^o�
DPΔ͐�6g?�k�ix�@�>l�F(C�����gS$Yj�������f�����Ć-�	1���Ѱ�-Mt	��ٌ.E�$�B�L#\�Lc�nh=�?�H]���a���KE�I�-H
���b��,�z�p��d���J�7�}{q6��i��
F��xEtt�b!1��(/AI(�]xJ_piW8Q�ā5��
U1�0j�����%4nZ���U���Ȯ�o���$�X������������0l�}    �0��� �n4$�@�]`�IW�O�LuBh@[v�4=�@�;:X!���>��O��ʅ��t�PBc�)Hx(C׼�O����0y$����i��a�x`�����?��������=�2����G6�_GJ�xA�yW�S���һ��Tr˔ذ��J�uӤKc��Z���m_/�_��y\1c���7Y�<!^$��<q}��V?�^�xd��8��O����HZ�]�o�H�u���8���d�ha[%��{1ƶ<}�5�5�@?��2�r�>z�է��|�Շ3���@��$� :��\pnt5��-�?IɪT����9qߢ�n!_����)f�`�]�,� q|y�*~"�S�#��LѮ�f,���*��f[�h�5��	��_a,ANe����p�(�o.��wX}�YW>��O�1�X�@G��G4���5�i*�~�Lk�
M�P^�V�7�*-���Q�B�ɳ��~�X�{+���<�O�*	�^�('q',^k������+�r6Rd)������7 �0xeʞѓ�r�p�I������F������^Ҏ�|?�L^$H�t�/$���%v=�\�{�������"��c#���Ϥ=��vu;���3���`��J��س�Bη�3d
��A�Ϟ	fI�o���&t��DDdL��-�?M�E�b7�sor�܃O����e#Ȓ�P(��YP䌔	q�H=�J�^��y��LU4�A���*���bǦ��p4P�b�h����^t���aC����߳�	4�וw��5�N����.��@��e��F��if\�4����֊�h��U s��p��+K<�bA�U�T&�s���Kx���`�Y����G����M}c�I���Vq��#R[}S�F�	L��oַ��X�o�8xƅ�����4���OS��.79bD�e@�i��������8�m�;W*+-�^��AI�'Bu��1.�Jׅ	��:e�*�+a��v��~K �. ����'vP������)���?���M%�ţ��ؼ�cs.V��;�^0�]�e\���)���BAu�G�zYY�@�'[�
VT�J<�3V�nVLH� ���P�w����`e:Y͂,<2V��
'9o�U  �������}�~�vN��\���|�m���&8J��@/C�c�Nr�����0�x�o(s�(R3�
"�a��\�&���	#T� >,��������F5ᤧ��w}t�����,�������%u�z�Jb��u/�.��~r9�b��A�F�w�9t���=��+s���d�3�5��[=C�\`lXra'���$#���ǩ�ͣq1&A��w�+U|Q>�.U��EX7y4��s����a�x~�O�5�@��ꏇ�����8UcӢ#�^��������[SF��f^����w$�5�k�D��p�!vB#Y��b]�[]l �K�n��i�c):����%D�H���"�����T�TF�<WQr�8���
e!�,g\@���-E-��Zn��`<a���@����㗡25�mDm�K����Z"<y^�IjW�h/Q��!�%�4�{C�u�՘��-Fzi=��p�44��a�)8�����P��V��'1tz�?M)#)����Dvtb��Z�U��H⹜W(���Nl���2&���,�ɉ��O�p�X�����Q�~�-S7a���hԿ���ܠqlm��W����:1wU��
��NL��H뽮���z/���!`@����5�v��	�|ω��>�Đ|+�]$^��V��GW��,)�N��s�y���"���P�v� T�q�
ى+c� W�dF�n������p�G�6��vhc�ӽ���c���&��P��bg�6�n�F�\��}GN�4�NM��y��<�H���X���
�5P�@� �me�ND�X��Kq��-�{��	rE�[�P�Io���B��"�Uuhu_(�ۋUs#��0]���h`����:�Z��%`�ַ�]��Nz��f4��M/��������W�6�쵈tS���P��!3hX�O��=fJ%n���e�OR���~�T3��ޱ�3TRչ
�ԅ�I���0��C���������E��R��.� ��I62^�v<���F�&ol� U�/c�J��ޚ#lo2�.�:c��#Ce�B��A�X}j"?�e� br���@
���X�4�(`I���-�_��|M�I�ȰGL$���.������1QU}�Xc���6տ��A/���8��������ޓA� m������8NS�\���w��H�]D9٧��J�Z:�M��`�1aHz����5F��I
V5
1��>z�Oʄa�ā��S��|�=FLb|U�3� �x�~�-Cu��v��o�Կ�#��[[�G��pl�խf�ߚ�c��&����Ӆ��.��>շh������-��F��#�1Ժ�?�� e�)]
�����+�o���8��m 2U�'��j�Oj�.�	��G���+�1O�����=��z�}�!�� ��#k�ür��?C'�s��Y�o;�QS���*���}~����C]͝IܯҷqR��ե]&��ЦQ{���JZ��}i�T���(�¨�{�gZF��D�wv"���>�GR��p��}�{�5U����2���q���O������{��b����W��~���1��)F��C��3�/�ݾn_;���_o����K���{�Ӧs���/��?��d�*�+�5P�<���еT^=S�o�J�q	�� R���qC�&�QQJ� z �J� �-�}v�}{p����X%��qj���M R"ձj�Y���ݦ?0ҳRȣPC�䲃��h��؛!���řD�"bqѳz�.���Iu��OR� �xBԽ/�7�I(��4��^�*G���[ľc+b?pŞ�꙱݂g�V�O/���Fwh��3{cUuݿ�)~M�jK���n�hsG��{"m�����w$�-��Ƞ�}�{��q�4�f	A�P�`H��B!�-�?	`�yWY�jn<���R��5Ň���������cL���J̔wpE.�"C�+��W��[r;�7}tS�6_���ü[�Xqc+���EF�<X�����rU����"�ا�j�"նK��P�i��H�B�$��Q�Qi���d�����|��?�b�`��32ц�����J�W��<�N\�]�A�1��q}Hѷ���S�D�q����O���Z�����Qr��/�Uk5
a��-������Mr2�f����7g;��0���8$>ԫ��v�mg�0a�mw�-R�o���1�˱[Wj������f`���t�Ȅ���i�4%|d
-B�m9̓}K�W5P�R�7}�e�B��\�ֵN�9N��e1S�%�2Pd����h���&6�z������;��2T��j<�yP�����X:L$C�jN�YO9�uл ��q���
]�U-
�}Sh�=n*L�G�Z��M��jB�d��T��2�Xb��[�5R�7�vH1���BU�*U_���UTM�c�#(��.Vlb4��>S��Ǳy'��]�ן���j8�|ސ>R��[��PSף�Ŋ��
��@=��%Z��X��dSQ��*�c�H+�u��3P�x�jE�Ȋ�fd��|^y�ΣJlaE8@͌�P��C�Sσ�����1���-�
�*x�_�F�?�<�@�����l�)�ǽ��@�b"$�"�4�*���k%U�d��o�֮����愫�PNS�I
E
��z�����qY2��Xr�2�W#|W��a��|���XF����n6���Ġ��㻍��&@�9ݨ UE�V#dml�kl�{U�pi�}������ë�M�-(�US[L�z�\qJ�qq�'O�:�I4��$N�H����I���Ԫ� :M�¢$�u���~y�lL<	�9a^]����F!A^XpU���ˀz���)~�:i�F�������٦^��;������j� ��ɣ\��r��׽�a��FB�����������~y�!*4�e�B�<��Dϒ�Bӄ�U�Ox��@P    �N򦺴Z�a� L�F\3���G���D�{?с�w�~K�H/ ~죯�(�#���X�s�5�2��AP��S��,��\n52{��n"���a�	]�D�)�Fj�x��0�=E�m��i���5&�hR՝7с/s#	x�	s�k��4l�p�A,� B�C��O�EqEU�32�3U������M?�����#�9{R�o֣����B������p<���f&�Ä�8���]Գ�.��E	3���e�X]�U\O�~%U�.��H����u�" Z�q�FT�d^�5�G>��z%e&��J�h7a��y�.��p���YG�T���a����	��-��o�Hz	�.�	�k�H��L��}YC�1.a�@'�nt����,�׃nӁ�kRB�4�RmR)!~��j��9Ӓ��[�x1���`���=��|��M������Ų���7�7�����=y��!ؠ���/%�RJ㣶�\JOSn�'$}'�9��5�����Ү.�6P]9�Ӵ��B5%F��	y�Y={��0��@N��T��@�,�.2���Sm�r�}�4}>t������Yv�5�ͯG�U�9Z���>A��`I��<ԣY�`�*�/�ټ�
u	�aȬ=��H�q�������.4�N�^O1��l%��G+�G+��l%*����^��N�i�Â2�T��P�3<>�M���!,���[�w�˟H��Xݥ��Ĉ�tʿ?� a4叅���� �����m=CZں�qɪw�n�Fu1�о\�,��}�
L$�g{�]�da� ������4��Ᶎ1��W�)(E�� Dϒ��<'Lq~�j�!L8W\�a!?C�|�qR(v��y�m�3���^�G��ݚ:�U��FF�k�޷w:�o�jl����Ic;����;Z	HO��+���=��R�)!��"ab�3���{��â]�2BAm
��e7�#{�8��RJ;q��<M[m>I�!���we���B��ͨ"�tԕPR����1�BQ�tSM]�a���@���(�5�-��
�G/TE ��Z(��
3�Ai��փ���Uz�\�̭��������b�ό�8�]Kl�ủ�id�HP]�B����P��? A��#���i��\ƍ����TQ�ah2~j]�		J��uE,�^����T�9
�,n��˵����W-�ղZ/����������i?��Q��q�B�@�A��{.�j�FW7t*�,!5K'=�T%(?�+�2��{�xS1"I��dQ�&s�	.���5�}Z�;`՟���<�N������'Q�Y�!{BQ|�}F�NO���ۨ�E�:AR��gYXyK�j�
j�َ|Z�žf�j=���8�']��0�7��V�=1s=]�D����?H4q�8��t��%\H�'f���a�����/��p��`ƫ <�8������qCʮ}O�r��og%���DiTE���TŌ'��D��H,Q��}K1c^��s0�yxE��}�8�.GQ7�yBB(��p��χ$��,�,�=V�7����vp��A�m=7�o@_e����v�����ƽ ���bF��(l���Vt�.�=�+f�aD�rw���4��&�Ժ[C)R%�Sȓ�C-+��;y�D��Hp�~������j�@_��}OX�A�r�&���������".<�����a��l-�1�So*�79��q]������?��z�E����+��#ѣ�C+�f�l_����\�R�����'^�g�����<_��sm�pi���עQ5�G��p�DQ��,�g�jYΒv	<_��~�hD��i���!�hTM�,���)�2� NW��c8�#�.��/$�h��t�hh-���*��0��+�Vis͛�r*��h����{�� ���{:@4����hZ`2]!��e�@���y��K���[lM}��l�G������� qhu��I�1Xb	�	�Wjq,W�|n�a�<U�����Ee[Һ�.a�n�P��߇"���^?"1zsa�t�Gu"%k��d����ՙ�6	_��H��$բ7��z��yW������~��C8:���xR�',>q��<���ku&FӸH�p�yQ��ɜ�4�}B_\�m-e��0��t����o?�ߧo�}+�O/�j�� �E�k��q�������,��_#� ^My����h����q�8��%))7��_T�,��h��׈��n�)�m�ӡ���4Ko�/+f�e<�B\f3��&*�z�i K�{:L4��.*�1H�[�W�"ʵ���"��܂�)��+��A�o��<a��X^�6�6���~8HH?VDMIe�	T�+{c?|��4�qc�	�������*'�_����ԥz�1�ܗ��X�4L*�.�bvubXî@���X�|V�)��l��e�t1óz!V5��}OLe�J�	t�r�锔̅E�,���4���=,���b���0���y
�Ы2W�q���Ͷ��`Ѩ�\����p��9Y� ͋I.7���E��f��t�hh=<s惰tKH�R�"f�L���x�Qv�gn-��dɏēY���}��^_Cz����������f��B�I���j��[�=bW�@�]S<7����8��[b&_�qE�ڑ�g,E��aMC����>�F�±�5T��VS6e ���GuGfon�h�[S��欂��W�)�z0��,�w���ӻ�N�4f�c�؂�s�5j��rW0������d=�F��/����h����@	~�epCT�U��G}�%软���u>�t���!�_i�������i��͖�nٷ�ξg�䟴s�������O1�;�u�w�u�������$J�\S��ӂ�N���_�W��у�>Wծ3s���>�i�om��?e��-�?����v��7˹���;so������5sw���ʩ�|��+����;�Щ��`�y5�^,��}�O���\%�̙_-�UT�<DO��yx�� ��G�����Ӛ�|�-�2�䉳���nl4��N�cC���rg*(��)���8��:�s��"�1�=�z�.�M��v;�������w_Ŀ�%����5�A�{���A��~�q�"�=��sꖻ�u�>�㿿}o�{�jDu�B�	jW\EՎW;x>�0��-@�0�W�{7�	7�4� 2�MF��t�ǭ9T�G�OP)4�"�Y���a�"��<�߂�}O{o'�$M���W���ug�0q:e�X��Z�(m�޷���	�ø�*ų���_���x��p#���pOF�^F�ZF�������A�xI���'�$⁫h�6���ݽp���^߭�
���րM{ʯ��&0�c����u�5��`����n�,�"�'=�u����#h����4�s5o5Wi�7����I�y�j{�L�w�� ��H5�$g�2!n�آx��Rq��Sq�����x;T0���!)��(�,u�~�m�}3MG�}AI[Й�+��5��Ms//�i2y\ �2.� ��=ӄr�5���-���c:�$�M|^�Ӆ6A+8=4u��3�GZjs!�����p����=�C�v�w��f�=�P� oHĴˡ�3jg�;��E�E���o��F��#m�͍U������?B�g����ڔ~s��5�ў�~R_�b�iy�M@��Q75
M�RS��]�3�$t�=��E�O��"���oI*���H1�9�T�u�j55q���RMJ��bWP3s=�{I�̦��>�4ڄ�}}��}5V��:���{�=��!�%�ʷx|}O��&�����V��KM�cb�}��h�F���.婐��{��allyFU�8��"�I�WY!B�.�y����6�H��@.=/�N.F��,;y^�Հ��1k��iA�S���m}�)"�2��}�(��˜bfK����&���^�pqף��<��m��'��V���	��(��ȕ֨�����?ɑ��)��ZF�̢��DWX�8��p���9�;��I:����nDB�����]�9/0~*V��u�t:�"Ƃ����D�9M�N    U�:�ہ��sRO&��Q�m$��s��8x�5	+-��\�MV|W7܊L�k��K��7-2�{=	��cDut���w��V�4gjݍ�ޜ|��w&-0ެ�fR��'��A�H뾶�-Ckݏ�M8·�~^Ӵ�bݩ� 6p��IG�XG�B���v���Ć��j�F-b�2ڬ;���i�����SZ���1.���UHS�\�7��B�E��9!A+.���'/�6qF?-��3P2�����~�d`���6�T�t;p�#Ի�Y�[֝�+Nޑ�#��#���b4]�k�ab�`X�1�AbP��y�6hI4�ē�e��<�b/\�_?#�6�0�8O�?��o�曠��I�y|�{�=�������HL��?��*;�"��k��7����x�a
�"Z(�'��p��:8�`��*7L��W�} n��$:��sEp���|7�i��t_y�a��#�'W7�����_weݫ����]e�_�q��z�`�.�p�|�4��`]�6 ���#��kr�`&�� s�V������Ժw_X�����ga����7�u�������[�e�������m�q�ƅ��mݵO ������=L7)���n�àw�n�nv�(�k �6���j�~��"e��_��`�Y�¥��%D�%�9vܰ�I*J�@u�
�>^�ϴk�i[�C�>��_��r#5*�?��v����A�
5#���B=v���ן/1�!������v�.,���b�u�ddd��a��T~��D�s�#1dn�@0T�I8�2/�qU�a��,�/tZ�F��t�%̲����WL�(��yj��Yٙq��f{�R���2N6�?��h�Ї���o��H� ���yr�d!=�	��[<�b3ՠ+��D��_���Z�����@8P'v�qQ�||	�}�o�ϙJ���S-�=|��T��x��R��B���2=$&W��P�}pb�S�UU��<���DR���k�0)虜���Az�Ou3)C�L�~���&�CU$�O�Ƒ/��2��p�4]Ƒ�HA�>~�,�=8��UoYB�W�`]��e=���=P逄����{4~�/R�)�°�.���I}��S}��#� �Ÿ'�8貞����m�?�u���yBy�ݷ��+�����R�>gL�YQ �x��H�V��3.0�f<)_�~��?���A�����)�"�?���SUq��8���?02{h�Wu�a�O��tL�q�ω�Dl��w�QL���%tEx��A]�虂ЭyB�)�7_`�������a���Fu�ئ�(��Ǿ�K[���8���n�K��Yw�[0=���o�%=8��QL4����:A�:��%��b��E�'_��Do���*N>T�C�ߪ�?Q�5l�*.�ix!Hs�A�(��7����jD�J��Ż��:����FJ��P���9h�);��m��y_K���y諮��7UɻQ�m��I7G��[�m��:�U���7xp�.%����k;""$|�2ʻ���w1����1�` ��ٌ���ϟ��=�=t�X���g1����CI�D �}O�7�C�( ��K��~���F��W �kn�=�FhHQ<�U�}�T�F��O|�Og�e�;I�����k�	�+A�����|�@������h���\>#;��߉�Ԝ�`�f��úb���_a�J���ڨ��~�5�g��s<��3��s5�Qz�wd��z��W<��csL (���8҅����@�g0������| ,��O��-�\�u����b����HA��z���.�`l79��	�P|<���ݚ��v�W���춫����˰�966��1K/��x�}��K�.�H���I��ދ�.c�uD���ah��u�E@nȤL罟�<��G�<)�����\e��.�ɜ�|{MU�O{�L��XW�i��C����f�w��1ꬼ��v� �
�׆�$����G`(P�_Hΐ~Gy@�����4���Q!گ򀷦��׽l<p�[	:U66�X�r{���L
s�5����|;�S~�����B���2']]3Y���{2 ѥ���ەP��"!�2�.m�X'u�F>´�0��i�+B�W�5����$;ׅ@qD�-�뼩�:�ivAjP����!�b�*�H�^4�))�^\r��� P� �a<�&��j�Y5����/��H��ûMӏ��bR�ߜ�B
�(�MdǇedq�����kY�d\�a.�1L�T�5hX�j[m����>@�%��҆� 2d�Q�@��-��U8KFW�V?ff6����X#��a������#�;sg�������+�D�߾���ᘢ�K#<���O�U̡T��lR̂Rs:ק4KðH�C�ڴ�`9��մՋ��j2_u*gt"g/��_�_|����>�Ҫ<d��W|U���[9Uq�DE5ߚRM��	��t�6}�('��|�����Ǜ�:Q1_v�����d�bh��U�y
I@�<!>���{��ı�[�w�E� 뮵��GW�I��yp2��X�n��mx�!geb[$ئ�Lﯫ��Ӳɱ"f�朔e6ϭyV�ɳ'��=����X�����nR�`����__�h��/���]3��*�N�䂍 &,T�)tJ�4����҆���Ԫ����!	�o#=�w�a���`��r�G�a.� E_@�y���2��nT~��z<�.�kG>�jM��uh�I��'�k�6�ܱ'�u�~��������Z�s��w���B�k%�Y�?D�^����4��k�������]'�OW�������ͅ�-k/���p�4�/�,R�\�%�%���	��d8g�����f�xA����� ]7�ś\!CRv%��r�������g�G}A���{�>OQ�^�:����~;�1���w=��m�D�dI9��dU�;���p:.��,����8��#/�u�i]�oƢU�Y�� �O~�ޟߺ�N�o%Gk��9j�d��D<J�7��R(���h.p�B�2��$6��$R�6���,�xY��C��πv5dW�l��c6J"A��狰����1�0�y���J����K~�C�`�[�@��c
F�1�-O�G xB����QK:>3?� k�FZ �**�y���śd1)kd�����L�jd1�l��[E��YX��1�_��e1�Ҝ�>��_{�Xm�D�*,�~�[
�/�.��6(����/ �ӳڲ�� ���Ȗ��f��oe1}�jyE|�]!l�p�<#t`6g�`jI�Ai*��x�Z��5��I~��ǵ����Ԉ#j�j�^e��aN����AGcN3�<�b8�3�v�8�jY�Y\�j�4!�h'�&�qڐe�A��\ �S��?��/|~�����ח�,B��mZ��u�����e��wz>xW���"�:�x3y��J[����s�x[��?>�0�!���È�JlRj������dW/2��A�Sd�`��YÒ��ZR��2�E?��mj��i�x�~'�<�Z������H���jU�bĄ�t"�Sx�%�q�)�DXJKV0x]��N��*��ɖ�i?8�Ћ��hE�G+(J�_w�M�nL�n"�<<�N6cQqa}��� ��wJlɴ�PQ�V�	OΘ8��m�hk��bi��Ř�Q=Y%�b��q}?-fr�pl{<���]��?����Y��\5gug��;ɺ���µQ\�f�B��z�3���ɲ\~���O�&�օf�Å9M>O_���)��3C;2�6�����@e�6��05��8j��ϑ�$��9��G52�0٨%C��E�O�#b\Ɍ�_�TO9��-��{���P����W��X�oe�����v�e��Wח����r��� ?�Zď8�N��=���	�Pu�'|A��{�o	���+J��2;���N�l,'o9�`�ܺ`����V�1'9�x��4SJ�y�z��5J�"���Gtǝ�QӥX�ø�u0|Lሓ|�p(Ynl?�x    ������m_�^5�l�C����k7-�K�/�� �yX�Y��Y�����^j$Q���]b(|�Y��Fr�b��mQ�;�oN�d��LU������uGg���M��v"y��h(��}	���W�������#/�\���a�jՇ�|�Q������*��,����{����5}).4�@���&����o���Qn��&ҳ,�A����O`G�I�Ж�s6�qD?O�	�J��i#_9���A��K쯦(����R�[����e���@��r��]=\w� ܰ�:͑/f�����/� �~t��e���i�ǟ�/�8�W(��E���ѳ\�Z8�O�E���)q�c��7�VR�Ƴvr��x�GL�$�'�����!g&�~�U0��Պ��(��\�֋d�r�}�����C/�zQ�l�Q�?�H�T�����a�%��r aTF��o��9��Ϝ��I?��.�/塜ƗLz2�נ���v��|��e�g�;9���s�E�n�7%6���#-+�o��k��?e}���1�π���QըY�(�e�	��qlfJ�is���l&�e1��k&$m��9|�l�Uߗ�}~͂~H�¼���E��V|�&Q		]���	�����Y�g~�qT��HW�!�<����8n3˕�G�O��s��0I��wL�4rb&o��0�ӏ!�ǐ�0m0}J��?}y�(
�gLUK!F�ړ�@�ŅOo�Q��a�m�Ka��~�>�m�k/\E�����׸?ٝ�Մ�O�g`��#:�����!�w�G_I�ױ��N���Q���;�k�q��x����Mi���6��l�')gXπ��1��x�3
I"ya�턆?؀?���H��~�X]{O��_Q���Wa�O�����r����_�i��\�����u��[��K7 A�G%�\�:',��-����Xl�X���.,�4�d���	7Ba�!S��{�{�4�f���!qȓE��>F}��<�SH�W��*e/�{;�s?�I�{�}�JHT�!R0<�	Wb�=-����nŵ���˛���YN6�Ղ 乁��T��q��V��=j�ݲ H*϶\xQ����X��oj�'M����k5)��@]\�C���E�Pq&^�s�;��U�6�P��r�G���C~S�חW�����D��@� �4U��A �^�����{%�|\p�s\�����V��D
�KFok���H�'j�V��9.�ұR�Y��NdC�P�h���ϙ�����ԃ;��N��gIyl��c`C�'v��|�^���8�oY#V����hR��*[�]J�-^|L�zd�Uo�t��x��O�$�nF�z~�w�� ��g�<tg��%ˆ�Cf��-6]%jQdV2yv�/�g���~������=�T����ӝZ��������l�eqWk2˟�4��-|�Ov*�m�N�������;>n�x8�׷�'��ܮ;���z_�}����EG�	��;�h��0�4��([��TW������$��q�4��q��|EC�6-X��(�Ij>L��e��y�ݽ Πw�}1(o�5V^�_�f7Ӌ!��R4�b^�����*]����?�23�-:6(��i��CA��s|�%E@���R1a��dۿz��������H^$k=_Ϋdx��Q�cqW<ssl��c��_>]o�i��w��Ǵ3�L;��a�'�`p�UӖG��^[SUz���j�+�%��=��.��]���0�4]'H�,��B�Fc9U/4�_���$��5<'��F���[�N�a���i\C�_E��\�ԍw�m�ϥ�zl�*ͅ�H���FXSU���=E��k�W��O��c�O�rd5��`�K�^�LUc:EF6�+��T��Dm���h.U��xTõQQ�%?/|�T5b��!�aW�n6�'q�Vi��l��ɣܖ�<>�*�Ϩ(�}h���4G��H�g[ڷ�#�!D�}�+��ݨ��d�|5Zƹ�׳q<�Ħ�KR���ц��#=]��@o2�i�]���byD@����,&wU�z�%C1B�[F���f{@<ɜ�N9W��[9~O�5�R���$*�	NWW(�<`i6����eK���R�Xg@�moi����n�BW������3#�d/����a^�~��
X?��(}X�L�N���C�:���@X:JK��־$�R�]Jz��bQ�x�T��A_�%��E�f�IF)���M��wߟb�~�;F/��t���0����{}^^=.1 �GL�m���t�ū~^P0y�/%��gl�����7e��>�g6q�D`3[�Ki"\���������r`�b���maQ����@ٰ`@p8��[VȠI�)3���^�9�{~��w쮽(�_�Ay��h�[���p"NWo��{�����l�,���p!?���P�B&u j_�7ZG2"��b[�N��m�,�^?/��[r
��d�(��5��t�h!ay��}Mq�Z!ɪu��&�yZ$�#@`RM:����P���G�6ϲ����'�ׁ��u�)8�E���銊��"�TO#���ɨa
+ J$�7��_d��q�Ӄ�~����GۛU��h� E���H�.�Oe�  ��(?Kw�Ʌ��,�ep�Xp�V�I߳��((}�}�;�!��v�Ni��s�/��iS�y��d(�u��Է�%�����q�r�)�z�I׋c܁�� ���4-�a��='<:�q�tN�d�=�Xō��Y0Iqx�B&1��sD�p�P �������	��Yg@�7(��ߍ7�<At Cp��4�ݫ~r�ܗח�<p����p�
~9L\0������m{�17��J���	���$�����EB}�}�\s�D��I�9�|�Yptz�ͱ���%�c:Ӓ
���Fަ��p4^E�}�������!ʃt�ڽ�-F��n ���o���iԍ�A�[��~?�H(p_�#�<̲l�p�"�+�v��	�]N��B[��Ʊ�%ى���'�b��L�Q\ �i�.��rF^�=�� 0�f��Ų�	�Yѹ�ˆ�M}�<�g$l�4�l�����L �k8+Y�G�x���eH+�Q������qbJt3$m8)r �%���y��1q���Kd�Q��Y����n�����n�����>���u��1b!?7w��"#���>�lF\_(�����ڱ-%88�!ĳ\_#=�;�A!�L��z�ӥd�%����:������XruZ������h��W�"]��������?�ȸ�'��ۙ���a6�y���2��\x�1�g���4�s|?�����z��^,�M����Pu��לl�g4�
��-��^�k����),Q����\�g�NIR�1��P^S����$&l<�B����IF�s�JL�U�π5�Ӱ�}��[����J&<��UT~OC�%�wm
n��(�|h����z���:j�`�E4��	5^@���9�mv��i�U`�:1S$Ϗ߃DjZe�n�97U�e�$���p�f�Ƙ�HZ4�J�x���ѶgЬ���^ZD8�ؽ��Fn,хH
Q�t�z^3�Ϗ�A"�^��|�0"��~p���V>\n[�3�F�+߲�k\O[��A"�������G�:�빜Vé�p���؃D�!$r���U;���fs��5y�hS��;h-±�T"Pc8�+x��*�ܝNY�Fs����������j���S��W����)��/c��;�h�ޗbY�g�.Ct�n��Y�W������^{�C�Ϊ�#�q$Rm��Gfx�
����X����ځCr~	�X�t8��\/pvc�I��8�+b�,�Ĭ�Ǻ%����?�M�5�� ��K���u�B����Q`J�2�ޣ�$Ρ��M�����Ux��M���<~����]�I
7��o"/(����:LN/�� �S�GC ;�u�SJ5L0�K*�'	�����`�fO��ʜ�)*��l�[��INQ���HoGj�R�yՒ�d�t�|ҥ$WqZ+I�ό�����ݰ�o��*��}f���̓�W�ς�i�x���8,�O�u    �ՠ��!���޷)��O%k�GaO������Fit��|���M��r�F��$�b-~����D��6"���I��0�H�X���z]%�u�a� ��+�Җ��7�^�����s���s���_?�����ߵ�x�v����#����:}A�o�6�GN�Ҙ,q��TzѴ�ߜ ��ql��9����#�5A�l�\$
�,��_�-�a�΀������c���F`_2b��k���jԋ�Q7�F[3�g�~d�(� ��qvt6`�����|Gr�%�1zRj���!�'�e���]��Y��^I5��x���2G�Z�q���m'�R 7ͮ����Y^��z�ώ��nD�w�x�tF� �O<c8�t �b�ojK���"��9���f=��EqcO�C��NcG7aFw<R�z^��C�B�M������IJ���E��(����e�Ff���x(��>�n
H;�Hc���u�V$G!DH_���ᔴ΀se�����{�tCa�<^7�I>�ڝ�jg�"O.\��;�iş�P���,��(}�Ɩ�����3�7|�z�2r�A]1�����(�o��$Ȋ�nc�Q���@�8GL>C�#jr�jK
���.��8q�ЋYX�EԻB�g8�0�`�Aj��n!��I�����������@e�"����}eD`엄(J�����x lߥ���/�7'A�|���9�����C�T��Q���R����Ke*I�J �p]闂�b+�8�V]�<���
�0â`x�%�v� ߇p��/i�u����4}�/��H�WS^�2}�lay%c$�mC����I����Fp}�^��p�W2�2^�ڈRN�İڏ��_�G�\����?y���4΢[mx��읨����� P�졸|���D�ٓ�[](Cy�= ��C�Y��SMx�-�G���'=����!�rLrq�4�K	;�貿t����%�w�Y8�c����P�##`����`�Kp5�����Q�1mˣ,�'��?ث���4D�w�|�<�WBS(:q�0ϙ"�>�&yԲ�F���oa��y���9%�ۄ��믮{��9!C�30�����a��v�e�u���y������2}G�,�U����Rs��E˵���l�7}�QXR���s����m��n����� �Ӓ�v���a�4�S)���8?�._�ev.�i�!Y.6��h�L�w��>�쀫�?�V"�>��bx}�����P\wo���+1�Sid��b���nc�yV���<��	�����n-
j�i<�zk�Vb�@�j�\5�?W�z�n��N�L"���.Z� �iv� 5�1��;2/1�b8d�ʓ�i�Ѫ�X_KqG
�qk�܅�[����k�8��D
ː!Y@؅8��9�²�Lq�Ͼõxs�DR������8R��?�yَ��u]��LضT�;1D{\[���?��[�
�FS��wA0��)j�6�= ��o�d`��J-��r1J��!ޏ��_��<��_mp���dO�6�Cj��U��e�MdTF�&�����`8$	����K�`$p|���q�O86e�DI��;S��
1��y�,Gh�o�`(�)Лs���Aȳ�$M�F��)1S�R����O��d2I�<͋Vv�~"),�<�~���"/-03��>Φ�A�^�{��k/��-?�����^��uJqf���M�wU��w�D�ٔ,��g l_y��C��ϑY�Hl}t�4N��Y��;��h��������V[� �}����띵��ṥ�zx~�7G��[旞�(�{�v��?��R�H� t��;}3�2���^}6bG�5J*Dbpd��j��#:Y�R{��0E=�����\~�(�E�5mEx鯮/# Zߧa�G�?�@�q@J#%�0��S���=�b�/\����B0Ǳ����{���f0�W���d.5.��'}����c@�Yj�=����H��#P`N����1Pr��g�G"H���Jؽ���Ӽ�C���'9�o)�b�#,H3~�.����vV�?�F���*�帾ǬC�s�9��>��c� Rh!%Ҳ4s��1��4��˃ifh��==��F�
�o�Qcj
i��@����d<K����9�G�y�q�3hޅ%��[9�n0U�\��>ũU��˫��׈�m�s\ZI/mQ�>�r�,����sfZ��H_K��.��-� �k�$%��GI>IV�U�,���g�jN'�YϞ��5	���I�JJ�4K֓�c��Gg%���<�f��|y��]$}A����{m�!2�_{>yz��}D�-4|oyD��O���}XWT�O�f����QZ�
��)Q�H��P��t������ca�+��ݣU�π����%/f�]	_R�N��D|���_Q�fm�<����̿F]m���ޓ���)�afס�(���q�@p���8�%�sG���F@z��8��_���Cl<3���'�n��cZXb���5yM�� ��/���3��>=f�oGi���~(���2�R��i>��ZE��C�EE��΋s�ݒ	�BX����,�H~p�/�R�>��+m��1DYU�������穘�sK�5����B�/�ZM�g����P`\�g�1����x��z֩�M�Y�CI�������-�l����?�?;��'��oC	oz2�NC��.I�
�G�w��`W~�T\�6LͅW�����L!!���j^q;�Y�s0����w�ݾ����s�^�4-��[��e�����6*}1�n�m�sr�O(G'��f;��ծЇP��چT�5�
<H�t��:~��o�_d	l�$ 9�  �B��w��~lQ��������Q�XH���0lLK-�D!�tR�D	{h�����(��l~�:E�oEc�`� �e�Z�^B�H�p;��<8��������Q�P�OLќq�@)�p�ˌ�m�l��ѝx� �^�lQN�1+�2M��L3�Z;=O��fm�!���x�nh�������<�T�s���䨔(����][d�4�:8_��^�ߵ��%@UM�<Ĭ�C� �2J��9d�<�c��e�5����^/�I�A�E��im�dɼ�R�~�8xE�{}ܚ��m�p�9i�OϪ���`�Ȇ�q���8�g;��ܡҦDi�m��@��D��1��t��(ԙ̀�z��<C��IʔҕH!Q�s�!�,�sK2�0��5W��I���>F^3��8(�H�Z>�C\	Ȗ3ܑ��Wl���A��/y<?Ӈ�I�ɬ��A������ӷ�K���
����Ƴ�-~6W)� �~�̫�L���q����b8\l��w���� ���y�m֛��.�a�~8v��1B״!ϗ�~������lM�i�#!L$�Be��\��:�y�a�X`�����jބŤY��[�����3���AzWqpx9Hq]6�ݢ�SvoV�%���"d�b a�|�ϴ7�?B�Z����*������l���AL<¯�!����@8�cZ��{8,�	�N1��MQ��%�>2�4L_���A�L���p�b�ͅ�O�u�i��lQ�P!kf���� �A�W�v�[���d�?�!õ!b>=�}j�C_YV���gQ�# @A�k�p�N8��|8\�'�!�2������������&m���B�ӔѦE\�?������rJ
���I�~g
�:�H63b\ ��AF��ū��=ro�҇�KȊ�W��W�|���髇���ƫ��&ۗ�寻�YU��w�548<T�����j�G�C���|���a��P6����w������
���[`1v!�L��NRU��x03��n���#Z�j��k�Ug��G��P_�#��Տ�n�*��#��� F��1�Tu+Q#���`V��C�Ku�OqB!"ث��(���y��`|Ghe),��2��d�rSo�-�F��P4_M��X���Jc��W׿8�G)�6��\8�F��x5��XTG���������    w���a�B�~��7��N�����1���E��T���:S���{���x4�ku��fU$Q){	�R�3Xx��ڳ7��R/jva��{��[�ȳW���CH�">a����O �w� �K�����m�u&p)�ij,Ή��
�N#�����1���ɛr2lR��T��U���y�"�3��Z�u�<f�������ǟ>��__ފ�� 졾X3��������V`��"-_��Y�.2�"��������U�"�7}~�r�R#m��+�[ ��}����i&1S@f�b��!�{��#�Ub2\��9�#'Ȥ�̓�n��E��{T�0�ו�C�/kf/.|z��iy�9���e�DO��X���*��a丸z�Y1 �����؂R��!��$;d���mf��ln �F�F�s�ԁ;^�4;�SH`����E��G�=6�g��'i�V�a@���1ꂣ�x2l&����K�/[��.|~�g7�­��Q!��}Cz�6y	ҍ�z��_����O�O�B��2}ؖ�=�1�o�P�\�A�W�#w�>=M�P"�g^�`������8��>��a^WNb��O H2�G���`�����v_��Oj��V��ѴK�X�E��C��t���ǲ��!�eԻ:É��M�}���1�>d��cNp���#�h�#��� ��k����)��B�&��>���h��y�j&��"@>G��%R�A�*�(�lQ
~���h^�&/�8��H_�����3��슐�9��D��q���۾�}@�H�\�Yy���P ��R} ��}��ro� � �iǸ�K_Y\[�%;�T�Fr�nP\����qI���R�,���S-!A1JH|()��XCB'���m��eQ������쇷���/�;v������uX��k\Eۆ͊ڹ�~�)�B��i��s?
E�0qE �IWx�W.�}�;�w%a���<	�4	P������E�U�^Ԁ"�	�5QK4y�zQ�"�3- ebY��Z-�#��� t��~�%K��}�е�@�N�<Y���u��O]��z}�/���ﺐ y�A�����B*�)Amߖ@�eK���Z�Nc�)$,1�l��ߕ�#`B��b�|T�E��N�����y�8
�$��ZS�¹��=]���m��u�#�z��+��|�}���f^�"5�	���9&@:�돔���R���􅀏�{�՚�������.5�r��mz�o�9S����w��żPIZ�8.��6�i&$*͔J*l��J,
52�󭺗=��gⓚ~��亍z7����nc������qr���U�<F��ٍ5���1���o�Ţ�Lߗ��G����%l�A]ʩx������a����;a�Y>�z�N�:��!����&�;E��g��y	9����<����c�g�T�W��ͼ�$��q��������U��I����$&�(*��c*�f ��}@�cI�yC}�/FJ���d" �Qe��W�=�7g��@d����1l�w���
� ��b��֧�~}��A~svS����B��?�;6с��͉�
����b�*I+�C��sw��i��#���I���&�A��y>ƪ�X�J06Ε��ٷC����竤M�k۝�/��?���#`���믮�qC� ��ٝi���2dA]FY�;/ͩ��E���~s�(x�P4�VL J��W��h�o����U��WuNb\�\�0��M�T`�u�cH���g� ��<u�3�bc	"n[Ǧ��{���3���9]~/��8�y��o�=yy7 [��T_��W������sG�$�>� �8|IX��kjY�s1R�RHmYL{�r)��vَ韆n��H��T�{R�ՏB����P3���(��h�����Z�{�����ߗ�~"��S�Cy�\�>"Yi{�����>|�G^�0ȧSܤ>C�o�ߩ� y�̍v+�8d�u}[؞�!��\(����#���{�IL�Ҽ�G4����[�>��C���F��t
&QE6I�S^7ӏ������m2����"�蛪]k��j=Y�Y��z�J���d�8߻"a~�
� �S x�
����|y���)�^�S�����/i]Xm�;I(;�&֊J$ay��aC�2d|z�d\Ws>ęs�{�fR���G��@b���O��l��`5-��l��K9@�|0m�P���k|uoÇ0����fu�3�N��Qg�H\I�*��>�����q!��	��u���䥻>M_�W4I���~��t4��q]�j׿�jZ��c8�r@o�a1^m�h��c��<γ�3/�G���J�V����X4�6H�Z���� �*��*[#������L?���K�5$�/K�{6����E�8���xA��N��o9@2G~5ȿ�2��eu�K5����B����22�:�\R��/��@8��-	�mC-c���f��,5�H�/}{�3�����zIJ���!���:ǉL,�"ɸ�l�������矸�w�ǁw�6�|)�^��w%p#3̃<��M�7(Q$��L�3To����3�a�����������v���G�ն�%��ND�Iq+j�tUc� ߜ�`Y�Z����o&��!!/��r������N�H��^�*l��:U�g����zܰ����\_޲���+��� t�UT�<"#>@���Z=>*	a����ց$�D�ez��ɰ��fW�̐���r���)�ָb@7��,��e��Ƹd/QȞ(u+P}vC�#B.����GޗR����K���W��+�m*�]1�.�@�H·�bi)m,e����]",c[��ӝ��Ӑ�#z`#��6k�n�X�?�T�	v��B���Ĺo5�F��|�|i�{V��L 6kO��绊�	�v,�v�t�٫���^H�W�k��W�p"��5���N��%s�����E �����M��"����Oj	�k��u����t��\�sV������-p��.5��;�F�ʮ��F��`�l�~�����*��wF�ɡxH�%a�EՅ -�гxx��Y�bL+�����x�\B�˔.����jC�jT���f��� ��g�ܞ�x�&C �a~��J��y�0-G���7��j�/o��N9𾥃��y:i]��,�ô6�؁F�vY�[.umߗB9ĳt�{ć���S����4�����z��S���1�	2��G3�fw&[��y�"�M���+�?U�,�eg]����nyd������М�:��p�6�YI�4"��q�q�?G�y��E�9�Z�C\_� 9$�HE?�S5}�(<�/.|z�4�����A���o�MH��[r�.��n=d��׽+z����E�oUzc@~ C#�۔�LzZ�r|cY��<�1ZʝD�4dq��b�P����;L_4{�J�E����Qݬ
�W�P�^/��ǅ��K�߳/a���Ġ�����r��汙��ޗl�sC,��嗴��!O��􅾐��zb|�u �=`�T��2 ��
KP��$d
�p�Qp͎韦\��#x���/{��[8�w7�#!���꧲������p��/�T־}	��%�nB#L�� �!��pK.*��2\]w�M�n�]^��V!�>g�#9�3"�9d�F��b�q���DY��D`.� Gj�4�NC	�k�e�fG�=�G��/� lŅQ�4�\a�J��~_����+����?��h�{����A�0�
lR<�|�N�~����!�n���Nxy�\\�E�S`�	|��<�?�K�ؐ�!� w5�c��܀�0䜆�������]E���L�dQ��F� ��\����<��i�m����gZ�:�iQ���:i��W���M��%_{ȅv��[y�a!�[�/�sl
Ԟ#��s�"�͹>X���h����6qmm�v\��;�/O3��4�x5xgN�e�5��rY3N���Q�CiM���iS��i3��O�[���=&��tP�����A6X���,��    �wK�ލ����^�<M�[�}`P�3>� M�	�q}�*������q]��d��O�
N�y�63����MJQUI�)��C��7b�5)X� ��Q���JqF��ϗ"[J�?/|z�v���>^7�>�����D/qo�� yi�L��³�3�o1~���V�3}i ��Z0}�a�ɀ!���mP�8w�N_�m��'��-V�R���e)��T/V#.�������R��E�t�B۳���E�yHF�������d�J�;_h3��"Y=S
_ĝdS�u��mN?}v�𩉿�`Oj4�=e`J����g�۽cj>� 惠A�Bj��Y>�#�e�L��5'��W��t�K%����e2�܍&��SwM�S��E'��o3�{S�H3#�jZXS�n^O��l�Z��JY��ƛ���?-����d���)m���p�����mOI���O����uky2��� I@�ٝ��j\�E���OV��K��e����~�)�|8�@�m�l;�Iz�y(��='-���o���`_�,����/��� ĸ_N�Y${���u��LП�??����竢3{������B������۪�-Oӻ�<nLKU ��wT�'i��xZ~]$M[���
i���IVxJ��2�SŃo��֛*Y�������B~��FN�ɑ���o�q���v���ێ�1s$8��drZI�̡"�g9́;��d���-��e�P��}�ӌ7���������%
�2N^����OS�N�<�Q=����Q��O��ɜjC�!β'�F+A�y3ˎ�E,IgֳBF��g���;��f�^m���.Y����]��?�'�>�B8��Y��@[[P�<rs~��EpE�8����~X��rC�c���>Q�_G����ge�i5J����d����τ����\���Y�V�EVk�v���zz�b��r^����CNۼ���3��u�LsIi�ү����mANH��Co�3�&c2�Wz��ь�|)ů�6�d�-Co���e�f��<'�$]g�6�u�~���;�j2�̪����Y2Iv�u�����o����!�x��T��UUo����-;5%.�GC����_HR��i��Bl��z1d��%"�wF�R��q�-T��U�A��x���˨���oصݘ����+V��VD�7�;MCo���ܵ�	�T}@o6�J�YN�o9�l�W�mIGqW
�h�WC��jKogLN��u�?a�4a��T/S-��^إ'!���0�L-Q!�q��79H\�EǧbLA�Rc�)m�_�!J�E�XMQ����t�������RjV�����e+���F�>���|X��ߋX��v,�jW��b۶�ڶ��@�Ƈ��A��ٖ��ѓ�����������D�{�c��[䐽����fa��L�5|?����!���~σh�B�����n��p��V�DO5�8��k��nV/@7�(ˢ^���1�����п��c��Q�� ���GQ��Q�e!������p����H�4N3��f9O�������jNw鯲��ȫV��q��mY�Qʲ�h�M������)�Eg>��C��J��J�Mڼ��?�v~�7ɅJ�PR^��y4�m�!}�yx�dγ8EUC�!ɭh�r2d��WK��4�}��z��X��t����7s�1�~/����K��*Q/(Q�3�ƫAd��{zߋ�6�T�"o��%�>�����������#���}�z�0��Q�f���8:�;�s.��rVMIBǫ%&�k=*e]�D�� ]r����4}��d�?�$���������.Yv��p�U���%�嘜S���e�]������`x�M�U6^�a8i<���=m��Z��S����7�ZIN3#��	5fc��Q��U�B��ZW�X=Y�Ȑ/Q@U�8d{(V�|�Ŏl��9~9��{�-��f��w�a���Ő��>�!�uo�������u�ٟ~���8�4����p���LE]p��b�O�р��;Zey�	�M-O9���F2	���J�J�+�_�h��༥^�qG�Aijh<�+g����gk�YD��J�]EI�����{��d=^�6,�0��*Y��xT���3{L�N֎�^�P�Cƕi�p��������T��Y֔�XO�l\A�ONnDE1-�ʪ#�K��:����#M�`|���{<ʄ����I5<ل���?)l۬��Sskq_�iK6[�i��*AN�� Xo&I�'�4��s��=t�UZw��w�`�P��Dg����,����8�0�����?0��s�'�u��GCk�4��}��L����,�����$N�G���Ƌq�!�g�����Gf�� 3xK5h���Ȱ�N�\N�|T���2��-�B���'�{��-���<��v����3.��������'N�-"�o��â����m0��$�e����X��ճq5Y����bv7�2�&��kv��s6�N���~̃o�h,1����G=( �`��2�5�tzo��̪
2][K�k�U�d+�is���y������1;�yىK����w�V?�����4��� ��w֊<-�����|AO� C�<�l��g�o���fs�+����9��dq�I���$�Q�h8���n������y�vXc;�ӓ�Z�S=�z��L��gZ�w���ȖQ�B�s���V�#�Ϭ�:��1�<���l���6V��w��v���4���B�.kc77Y��Ȏ���b\>N2$i�Ԉ6}K�B�2n��#{�����/�u[I����#K�d��g�O�e��������k���'1�<^O�9�"�&U�HV�տ����L�������+�j��;kw}�����'��Չ]_��1%��^��P�^d�nL�b���7��;)�����7َl�s�g�3�Eb:�-�;ע[�P�����a>����W��#XZ'���xzA��-y��;k���	�\p�e70���ᰞ���"�_��%�0���O�θ�{�ܯ�7��i��g�,L��gI��df$�ɄՕ��dZ���i����.<�kݼ�)��y��k��)�d�ٮ�u'޴�l��F��\H�r���Z�oCX7V�^W�L,&�Z$�\��-���ﶝ�JםM<<�8x��b���w��4���rb��C��H�T�X�c- M���f�u��e�Y.�oy����w�~T0]������j-�cvǹY�I�kӔ��Ȼ�#t��՟�l5�/�6�zr�s��L:q9���ا3�D��/��vf��c�si�$�Ӹ��x�^RSN��ƺ����~�2^8��\n:�p:�����4-��y�-g��j~�'��f)۴ ��7��P0[� �Lg2_.�Yiet��TD��/lb�C9�WwJ^���n0i1J;��@��"p㾽&���
�`l��{32���&�9�w<��L}'���O��C�O� �͒�Q8���7ɰ������ߓh��D��B�T��>۟�%ϒ|���󻅥�P��=��X�_x�ɪ�jsT�o4�;�2_u6�Æ��p6���s6�P��m}8x����$#���(��Y^OK%�K���LW_?��:۬&�cjQ��3_�����wa��ӱ�ruahK�w���?D�q�g�Ά9��,���],�����%�������p�x2eYtF��3�4��sXJ�<��w�V��MhJ'�H+�K��k��T�b|���r�2G�4�����\��q�V���:9@:�T�P�t�uAU˓��G9���f���NQ��ĚUּNGe<���L��<�o��M�9�9ˬ�N�`L�v�h��������jG'���F�9:�p�����<�i�4�$e
��'� ��jH�q�q���1�� ?���^���p�7H���qP�WQ��l���$e*o�� ����ɧ��~��f-%�cg�l�rf_T�mC��/`ġ¶��:����,c�c����Mj-N�N�.��j.Xb2��)#^1ʒ�e�$u�ڏ"�8.N���ߣ�'�@/���u/�Hy{}�o�[���"A��y%�)qo    6���k�-�:G"zܖ�<(���3�gs8B��:�T2B��?��Nag��s6BY�7���BhO�P(w5ENQ����\��Ϛv.PF�ȳQ@*Ze�H�!%���_~�q�}�ݬB��Am���������
��C��%���������T��S�P{av�E�z��� �K=�&�ڿL���=&�|�
�d���ͦ�BI"��B(x?>���)T���
6�% +����J^Xx���ӅO����(��l~����oEC�P������j�%4��i���a~v���L�Z��,\$���挓����\
��Zٌ��{�AJy"���~N�#&���C>l�!����w����~<Jk|�a����|���z������|��~��O�?�	�����"�B�2^���y+��fii����$t8^�BW��OY����*=���:���t��L���Z��UU�6}].�N�Z;w�߭�����؅!-����۞��SaxH?��N�;0<	H]kU4^���Lg����A� h`�ќ难��ܣݥ���G�b{ݻ�a�_�y�px�]��B���\{}n�/�3N_?���y�Hi�C^�B���=�jM��=�q�".5�rg��OC}j���.`�w���ä������F̎��pЫ���#ar����U���ݣ��AťdQ� w����1|e��Cۇ�]��K9�j|;���@���eR�C�oپ�}[؞�!�ﮘ���b��b��O2��$2
Օ���Tn�y����P��V���'�����fJ%�+�@���9�o,|�l�:ٺ0�7�O濊��HY\=��Ӂ�����A��ct��5����c��J�2}_��v������V�RN-W���id리X����]�Gr�8�Y9� ��X��R������8��5���noQ����}EK��~�nؠ��p��e�F(`��6E�L?*�h{#��- ���	��2}��ʍ�;�928d�4�!��<�X�1�Y�+f��Ԁ��I_Ox�'}=A�ʰW�~/���ɲV�0��yN�w�ҩ�ů,U�k����]�u�Y���I�N9[�:���O��j�Y�p��mO\OCeU�b�(���@ ���'`�՜�+�gi&!Q��H�G�w}����]��]��ͶϾ���i�p�%��=�3��� s���fu�OE��6?��擒.U�9�|����
���L��~��wm)�vL�$xl:�Mr���o6}�T Uj8:�׎����2��5)��0�ȫLbS������C�_y7��^\w�mĮV�����[�n6�޷!�o}��^�~��ʛOE��6��@�&��%a�C���e)��H�LіŴ�,��A�����IX��� �X6�o��J�P�j		+�6S5�_�Dv���.�� ��%&Ƶ�Ro��s~A|~��ހ�ϟǫA��U;��o9�>O��_�A���D��S1����[�Ɏ5}��`��=d�\R��/��@8��-�{�����;�����Yjje8Ҁ�o�� �j�e�#�zIJ@��_�"�o��7��՘�v�K�/��������Ə��h7\��_�Ft���5W"b���Q�o����{��+�g|�f�ߛ����`��ӞЎ��p���6ގ韤\���������pd�4�q�� ϲ9
M�j	-�7�|,c�H�_��M�<�1?��z!뗷g,�/�`�ח_��=_\_^������!	��|+��^�b�e9���"`uQCƂC <�+�`��!�+	۩`�F���u�(dX��N��R�����2&_��?���v��N_���#� �2������w��u �c��^���l�u��I�����g�Hh�S���p���Ε��1
�S���#)8]��)Ôf��Hb���"3�p�'��#�?T:^�,t����Bľ��F *���CS ɿ_{�t�M *ǲ��!�eԻ:�ξ L�����Hl���{�� %H'ЮG��2�[;����;�+�� m�7K;����3��E��!��T�@RSNR:�(C����9�������9������w[N$Y҅�{�B�3�e3����5�U���Q���ٶ<�'�<������J(�$K�
��i��5*D�������W0
������'#�9��6���ǂ���h�<_��~EO��C�t�h܎��Ávn����zj_c�A�1w�^n�2o<�C��"��:J�����M�!�ս���(�	 �M�m�Z��l�x� ���h���{�Dȡ�wձ��}�U;R����ċf�n1�<P��;0�7�(������ðK��)J$e�Fu8`�vֻU��w��6����������=�tC}�9(@~h>�I���6���ʞ��l�sň�RnOqU�;�L<YKg�6�ͮI���{�M�~�B���)�?���-x��D[
- 6D�C!*?�/� �w��.�����^�z�0��d���`PL'���s���*�ɠ�6����	����[�@^�X���:l���.$}F�X�tM������3B{п�[l1;+�e���aQ��!��]�����%��P<ǹ���/h�R�����M{�n����O��c�|q!����B�f�G����8��d��C���x,�}�+Mo��N@�=a�#~��P"1%jw���2�Z���t�G����E�2�oL��z9V��ꫂ`4�aOHmQ��8
a~�֔��wP�V�����Q?,�[�W�)�����-?��:�|���߽�0�����]o��&_p��B%�� R�uA�"rK��}<�kM�ѝ��2�����$�\Ѻ�{�QKO�Bٮ�[{�T���s����%H�q�'�sx�;px�??�Q�њ>�z;�g*��F��:��ĝ!<�ߡY��[��W8#Jn�-eMɯ>�� �@'ݾh���~ �_��<�I��̱�"�I
-wtQ����;�-`2^z��7�җ�������9m�d�N�(��Sc��L�IA{�k��g?�M.��v���b�9?��KG8�HuS"���Su���"�E� U�	ñz���:�Ք��T2 �h��}�q��?�P�;�e��$,f�0~��y�F����x��6�o���d�l0쫷A�ou�����~{��]u���s�F5#H���qմQ7巚i�6c6�e���x��|�yV��'?�mj�7�wм9����a#�]g�q*�? Ѽ)�������t�<��a�+n9Uto{5A�A�b2��-�0����{xTE잃G.���؄��,	ܟ��q�m_�@��S��
0�a�C����x[\G����]��:�~M���7�p�Iϛ�i1�����/�b�w��_�}_<���O��������T�#�h�y,��ڐ�����]���t�z��>w�P�"�"O�S������R�y��)|�ΖO5���jp��]�y(Ob��|�<lw���?A�aTB�R�qy��2��(rU	��d��X���Ô{��0�f����TTS�4Ė狟�ܔҗv��V^{�����Fw�^d��q(�Ĭ�U�L�t2-��&�?ݎ֣��xZyE��p@���k�|���; }�K�:�C�2@z����!�E��(�X�Ad��Y���2�i��(S�8r/��}�a`����p������W����}s���d�O�b��!H���1* ����,Z�+8����`ۇ?~>���z��9��e(����g��� &*�\�Yi�\��g�d����.���i,��,pqx�p]J��&�q
��?�c�\>-����?
t�� ��c�2�;�e����ŉ���\]��7�����4�p�o�M��������4_�J�:�г�{�:�Iv_�Y9��Bb�1}��)ˡ��F1��#��pN��I9E���?����s
H�'Sq׾���F��ox ����� ��_,=�� SQ�j����E�,����tt�n�'@E�bX�Z�槸+��2b��*�#�߮�IhE:ZF��*���3<�M͕{�xP���Fs
�[x�94�ن�    �pe+��>w���<CB�b.�@��9��8]�4���o�G۪1����W�~�����m��+���*�����n� ��X2A�`�����6^�%5�e2W���lRΣ������ns^��~���}}$8٘�e���
e�i\Z����L1\���1��$�?��u�or~�0R�eQ(��M����F�*k�v�#�+��85�I0��m�\ɹK"���KH/w� �^D��Q6��V�8SD%��dV@�v�"�"Ӣ	*"� eZ�^��x0��zI.��-���rSC)�S^Ѿ�t��Ce���ە�9U}&;%�sS-�̤�m��2X�t�O� -?�����S�m���8���a��=���*��(ts���p@��yAC�g^�R�zM�/����zd�V����̌΃��0��$�4�ەC�^#D0w}UI
����+ݟ`��$�Cm!.�@#_��J��,Y������o�!�����_�M�/�XY{gZ9q:PvW�oW��TD-��e	Ė�&�9�4p<ݧ�P]�
�:X]T�����j)D�6Hh�����&Cg��:��b
�ϩ$`�6Ev������\�o�?��������^�5����:;���v����7 �d��u�Q4b�U���#�����:�{gGMd,͐h�f�*C~���ce�����Ӿv���q�P	�I	�h��ώ�-L	�a�v�gG�H!-����3�ާm�u��:�����@����(���<pH�Hw�(�������ZŔK5�����y��K?;��Tag1I���"�F�O�n�J�P�������[Bt�z��'ڽ�#l��2��N�VK3.��ԣ";:���h�Vɜ8R���������$v�v�G�"%JΪ:
&j���G'G�h.�F����\]���ǯ�9U}FTMY��/�NH͵�Ϲv.xt
g`X㡾zz�{t� �C��M>{�F�ڥ���C��s�4�Ť:w>��P��^�yyQ#d�aD�B�|��<_D�
����ܛ�-����y�_����O@���T�v�N-�N�Ee��MLUd&K�c�Q����k��6�����%��J�r���J����ʭ˅�C��`��ß��Y54��xz Û�(�4�6��8��JD�g����,;�.5����-�˓�}��5�%�ε.�7G�3�þ���M��~O׻��0�R�z=�a!0�� j{GG$�mdd�r݄F4�����瑎�_�u�Gԗortʹ�DN�TR�9��pG�[&� �+�.�b։�ľU�()X����/������k����
mRek���<<+wZ�H<�2��_�]�u�ȼl��6(M�5�	�"ƈ�ј���/&��ºxjh|+���R�txh��j�9\xYc���%��N�n��x��|�Y��:�n3�~Ȑ�zM֥���o{X����d��z4AO�!V���xv��E
C7
�%�7�V���MX�w���G�7|%�K���ڳ����e���R�]�u��j� 6`q�S�f�s��ARA��9�o�sv�Tq�x���f���""j�ʦ8�oW.�jz�rEc�����I��nz|G��� g�y��5<ŵ�u���������+�0�Ku�\�Y.X���|�6s���$�w=��M��o�4I����܃&��:XV�P�]�U����r�LF��p�����2-5�1?�)/�27���'#1r���WT�f�@)��H	�S���w�����%qk���8)Υ�/0�C%+31�V�#��֟�Å��Q���)2e�5��`�C{�Ѡ��߮\D"��%N,h���l���W��r~("\'��b�W�(}*o̓M'=�ڀ��)��qI�E�v�GM����j�Q���s�$�V$
�W{�.��p��)�@bd���W�ͶTb�v�"l��vԈ���@"��Kq���"H-'[Zle �&Դ� 
5��j����qC�Չ�d/w�v��h��.<d�E4���ߥ>�H�8��#s��El��e��eG�F��#P|�̹�d7��x��h����PB�ԅ� ƿq#��Z�~�r1�{1�TR��JL���Ā����0Y���&�_ �2���D?��{DU������P6�'Kq�S1���Vu=������oW����i����e�ț'*�V,t�X��jti����Ƥ�F^����������
H%E�lVv�lW�����a�LU)H$^R����p���D�V,��0R�d���0�H=q4y�j��W�6�Rv�&	k�+���(0�b�pQ�W�Rj���_�zI.���dD�bn���)=�Ht[�*{i�~�r����XL���3u��C�l�^���<W��n���MDL<�0&AQ�v�I8�e1E�1�S-�Q�.\`�$��!Up �⪅���Ȍ���mS���sC�m.ps{�-�?U��;�.�&�w-��B9���0�2#`��<�����A 1�CB'%�77I��(�3��'�1����tQe�I�v�"`��"6�%fPd��V�*�(6�[���^D�(���WҰ1G�,"��I���~���¥T=8g+۷蕡5/���8>8V�ݦ{�m�/����W���}RVIl*�V�ES
Q;@� �~�2 Au�JX��@��ŮM�"LM�ë����<��J�=ˣ�@�D>ɲ��ە�T�>�P1�5��='	�[�,���ڿ�eۜG��J	��J�o"b���^��+�8k9��+�A�GQ���}=/�j�K�p�͟ӭ�-�B���\D<���Iʶ~�rU/�V����P5UuP�,�ص����z�o<ec��E�"�"��6���v�r�����k��/�dx^��XaSu�%���{L3V�ˈ�"��A;a(z7�*1��ە�HDk�B1Bi���$yb�vڮ�Z�"���*����ժ�l����' ;P��oW."�a��SPQ��s-�\�R/�j�$���m�P�;��̛_�EDhG���~�r�hͲ]M�#E�a�%aĥE��%�����V�)��J��i�05fI����E$b�����\����dy^�7/Ȃ]��v��ۥ�D�91��7�IPT�]��D�B� e¸t</��037��k�E���(
��wíb��ZI�f�T��L<��.��=J�"�dl�U���V�g� ���4P��К���,����[Oq���w� �!���=��"�h��*�Cb�W��K=���Y���ڗ>�%+�P1W������"<ց@����Q.�<'4�;��� g�I��<p��
"�~��o����*q���*=W.Tt;iTR�W�G�\����Ǽ��I�)��N#my,�����Y�H�������پ\��sY��H��Q.�&�@"b��ea�fv���"���.��}ɔ�H6Jn5{5��YG����Q.�C�0mM%%���Yeb�����?/����9K.�:T�t[(ɺ��c'i��#�}�ߣ\.�!N��S�8����*Z9����&xq9^���(5Ζ��א�~�r�/��j�NYn�=+Y-�4O��R��7�_�x��������s�+/
�ߣ\.�J���B��`�V�K?�Y���|��Å7�ˆ�tfJ��g˅�#�$r�ߣT.�u��W�CU;��㡎�M���_�vzX�mc��N��lEVy�"����%�Q"#�{^ M��K��7u�N+*Q(۬X*�mc�a_ZL�H�~�riU�����p̝�%q-3-���{A�)�ެa:7\��5��0�T��	��AIyF��bN������C@�W�$ɠU`Sۗ�:/b���������r��H���IY��r;6>b�E��rNR͜+����a!sNV�2��ų�@��F����b�,M%O"C)�c��6b��\l�i�<p<�dVЃXL�m��c���x����u f��	����ȰRH�,�{Do�A��v��̭XhI���r`"u���;�> �f"�ތv�n�Sj��w�/�Ϟ��h_����ɦ�[�{��X���A=m�������ehs>�q|�T    %��7�C�8-LQ��<�ڋ� ��
J��8�99��7�f�,�0�Ι��Z�b��B*����|	�DD�J}y��7(5��t��@�'�j��0��B�͙]P������B5�"_�n\j$��P���B�:k��:�u;J��e?˅G�H�u��r��Vr�b����\�J.�Nܥ�Yff� rs#%�E�g%���������3��r�K?ܔ��������TVec��7�Ph�G>�K��r��fr���ľ��K��o�Y��1X.\3�t���a�^\.?H�+�s7�f�'K�k��i㘻o�<H�K�G�7*�w�;H6��pDDJ�p'7D��sU-w�t�H�k9��p����/m�ɬ��R�=GY�/Lϒ�w�&�4�ߥ\2��n�9�慎�Ѷ�"���Hl�**�d��t�D�F�8���2�;��6>��i��$���W�䂫�"a�E���d��.7d��p��� 9ھ|F��|ۉo�M��,�e�G��k����{�� w�{���/�w"�=WTFK��#�Rh4[x���ho��ڤd���G�����Z�A��\�8�~Or9�f��Ax�{��5#Y��*ǅ��Gۭ���شW���r��A���f��f��71!Q��4�RL�[��I�#� cy����[�X���G��1�S��j��`����4N�ၥ�&�I���+J0�H5(��6�m;}&^����7���6��L�a1�?��`e�<�L��h��L���?�����X�N�y-��X�'N�5�C�; Cx:��÷:�e=m�wX��I_c�{���=�_��3�Cf��f|����<�o����,ɰ���/i���;���6כ��0'u��?���߿���p=\�G[��=�����]��L�).ƏO㭻�M��=�3����B%W���z��!:�T��4c�pWg�F�~��[w�t�� ��~��~wݝ��Y4��nU4�|�L�����b���~�t׷n�s���;&��=� {������7��][]�)��kF���H�S��z���o��1�w��賡��G���x!?ι</4V6�����_g�����VJa���im�}a�:�{J�h�G��M�\[p�K3Y��&/���(��HI�NI�%��}��KiOpkE��X�m�I��vkEAIQ �}7��-B�Խ�n,�ha-k|oM�E�^*JZ���I�a,oB/^܄'����%��n�֔l�-`����s�f��8�je�ܬ9R�z4��PS�Y=�����������g�,�D%G���Ї�J�n[k�HZ�ν�$h p��8�N6Ժ���[ƺc������E�t���4�z��p�l��{L㶷������)�ZE����Su'�dv�m,� �׼i�<��D,3��Y�X�i<��Y4^���=����;�*_�-�5I�P�Z��k��`8��.�L�h����z_vj�~@�����K�F����Q��uϝ�E�;�3 �3VKȏ�q0�a�,���w/��K4�~��h6��GA��q��`X�wy]Viw&���CM�;yA�fj�{�󠥧�P!ܪ�=ȃ뀼��_3��o�tP[�겖��F��b�n߈����֪ů�x�8Qd�zT�^����U�aQi�Z���D*��Q�ѕ����-Ρ�h�Z�9g���J�B����}3^�s�کuTY��Q@v%YF���w���4��K�Y,{��t����o���?�����эr ����=�������]$v�"�=bxTq���mB�:���(�UΣ����g�\B[y�+IQ�Y�v��jK��(Xz�f�N���p
��e��P^*Ů#gYi�둶p]7�1�/�V�>)���o�2�:@�\����zd*�pBM�Z���R^�Ů#�Xi�A�����=�ЖFJ�,
%Z���$��y������,S�+�y,�D�r�_Gެ���H[D:-�;9���V�q�M��-Zk�JJ#��$&���]�2wI��r^S�_GʧҖ�B[��K*�_�������J�Zk�I^rL�&�����i�Shx�*r܌՜��H�T�reڪ9[��'\��(׊����Q[mI���� ��\8 Q���!�3�X�G�C�:�2��ڒ�^:��e�Z�M�/�XY{���%�h�K?Zis�%5��TS#�5�>�~��J[�Km]���2U{��m�E%��i;��udO*m�/�uA>������m��Kr+�x�w#x^_*J�=�7�@,82[��ZY�-P#������g���|�XP����?�|xɋ�p@u�\'R�k��{o�~����zw,�AkXrw������Vu�ֲ��b��8_D�-ϗ|~+2q�_Q�I��]�/��5��4o�-"��Z�sm]Q�	i범ٗ���v[mi3׎J�W�}b2O�b������[j��e�����d��/ϖ<��S��y5�'�n�-٨�vD�H�������ٺ$w�Eb�}>��"�W�v��H�������޺��E����m�%�ގ^�ד}�?~��,��E<�}���"2f�VL�\[ד}�?~��,o�%�u���V[X�����Vw�s5@"V9���
U�K��Y���Cn��XpΈ��Ɍ]�ōg�7�3�G$�(�Vs(�M������A#{َw
aA^
x9�e/Հ��I��?�^���?�Ho}*qZ�sm]Ob���y���]�p��X'��0�v���5r�կe��ݩ��k�֊yMibW���v��>��d'? Z���7�w������-���z�I��5�x���vTZCh��1���eH����u�j��1���.��>�e}]�%�J�t|=I����dp�̽���:��,��#���j�c"��ձ�A�uh�q�bj�B�jf=�0��]~�5��{:�����?@_�f�"-��l�m�$m��W���:~��>mŷԖ�J��vd�\I�Jh��������g}[m�(G���#p%�+�������V��c������ڢ�������-JCg�8���٨�^I�Jh��9����I���ӷՖ��G=W���:~μ,��E���@�6O�����HȰ���`	�Y��U�J"�M&}|F�J�-B[�ϙק�>���`�'=W�m��Zv��f�\q��J	����x�̍*F�� r� /#�B��\I�Dhk�R[���H�@�U��Q(�S�2�K
;r��WP�P�� �c�z^��J��W�ں�zm�����O�X���e���U�&�idF� TMU8�4y� ��\�r$�V}��)�5�X�.#�/H�eI,��jZ��y\�yASc�MU~o���e,�^��6v���SV����:��[�B1Bi���$yb�vڮ�JG�!x=����mɚ��/�K��Be�ئ2o�V�;�l�)ya9�u,<�Rυ)�b,�����2�S��j���)��RO1�0Uʤ�ŵ�$^�e���+F�H��KK�P���e,��?[k�PB1�4�[�2��d��u�*,;w���0Lo^����P!��x�����h��J�dގX����ȴ�?��7X,N�"?��>+�$�}����7엃�Ot�*��?�AT���u��Y��P�.�����v%>��ա�N���ct�pu�^�W��B�g˚V������)V�T��R�T���^G��:E� �?��h�y��D��*�#�s�A�����y��u:�M�J�TZ�SX�|�} ��!ʻ�_G6�]� ����_GB�x,���>d;?%�_+�c2�ײ`7�q�=���8��b��̧�9h��jǓ�d��3pnB�ܙ�5�a���`�V�d)Oۧ3
[I����6�$B����[�~8���=�8 ��A��э�����?=0���v��YpWL'O㍪����e�>�>?���};Ù7�O�q`t����8��Hk�y�S�#Z��Ӝ7C�÷�B��b���{���`Խ�+0��E�����O�h���Ekʧ8����G���� lx@Ъ��Jbf#��g!�y�O    =�<��x_hE��tֻC��z�RڧY�R��̟Vq?�3�c0������bNz1{�J��q8��Ǔ�榟E{��@�@_������a����QR�᠏��C�v��Ň�A��w1�Ͷ@�<��y�mg[�Y���0G����]���b'uS��,4ܔ��=�m!�T⯜@�)b�����[ a"?1��3���U]p��Bϋ[�-7A��E@n�����.��������r�H�N9&�~`�^���[x�ݺ����+�N��4�3W�u��_�A1��#�u;�x��;�\@��@�`	�ٌu� ��!;m�0dC����N�Z���E��H��,�v~[�Kߜ'~�]l��N}®�bC�&�q`Y ���$�7)��A7��I��_��I�������}^�p��p��C��C�q���\�&�Z�2��P����y��W���݆���������E���<f��dRγ(b��0]�y�ҥTջl�dQ���cV8���-f�1�����uq�#����P�~��Cp�!@�&�WtO^���	��>uX�������6��=�ۜ|�/4d�H£�И\>>���A��OW&�����O`���֢�4+4g���� �hi��ٱ~�N,� ���"���>�d���XT=�\ǥ�����@(�;�
%/����VD!��%����G�Ւ������`���h+	~��������s����L��A�Err���=\��b�?��p��b��"�&_�1��}�������ز�c�Y��	D��<C�4A�}"�,�1e�a�L�bf�.f�<�
o�������m�M,0���W�m�:��/��>�ӭ��[�gF_�����|L��2��{�lDM�jW���i���!�?�O���P�:��!�C�EҦ��@��'(��I��߅~~[���_�}^h.Z}OW&��%�Y�̋��?�Ƈ�h6�u�cV�6'o`4����8V���z}��Q�Uz�'�¹��Hy���ۂ����?e���q��)�H4n�����&G�n`Y^B=�\�{���e����d�
Ermlկ~�(��Y�[��qk5�X�/�wp��P�{��?�q�g��;L"��'���$N?�Z�2H��k�V�x��p���}@���H(�q�Jn��������ԁXb�#���?�����`G����]���O�q�dQdx�fv�s����"�V�^��\Gx����n��{��!Wp^8�O��Ȟ'Jb��bn�s^(��N戹���u"jq�O
�į��vT����\������>q5�9�"�����e'Kʒ��!�n���l��	&TW_2�_!�0n��j]�@�i��~�E~�
f�E��n1}��+����8@�J��"��]��G��Zd�n�=r��=�U5�a8�=m�!j���T��a����j�a_G�hϘ�3-2}�:����:|�E~[�ʿ=�_7o����}����hW���r��h���_c:p7z��}� ���0&Ƥј��	D֛���	��e�@>����F��Ov4]2��7^������Gi�u�y���Q�3>��F�0]�B���j�}�^�A���ZD�/�����A�	�,{/H4���Q��U�~7ҲW*�c�X(��(74J@�.�9�M�!����D:�tU?Co�[��;�VY��y(BL�3Y}du�Ҳ\��k�a҅�����B=FѱM���Pv�QD.���o@%�%��w#G���R�6�� E-���pGe� *����^��>��n���|q�e��ш��m�X�d�9������1Ϛru>�h5�utztl���%mO����⢦�~{ю��[C��T�r��?��0~RHK��&銍�Njz����ZE+�-�'f)w#�()�e u#���Ǉj/��=��q�|n���R�+7��d8�b�9��ƍ�tT*I�Xq��[��=���z˥���Qu��غ�� U-��]��k%}�1����^^���~5���w0�lh�:|{D_��lg+D7�Vh��i��b�:�?>�'��0LN[#�kD�'�:*�x�m���t��əK:V��J;�*@q`,�;�%�ى��0�x�y�ɵb��.��^�晩�NbC�Ж˂����p<�jo���.}/.2?a*���EձT	��Gf�<��R�r�σMW_C��BB�?4�V�Elǀ�`���2F �4׌���[�rަ	m�m�_)i����4O	�m[F��MGJ�Pv(M��=0\�`��� ����.�3uM�txO=��W��|�x���L��*o���l��G>���ƴ�M(Mm�H�:�D>�������.�JGlb��>^6���o�<.��/������L�q8����nG�t2�D��h�_&�7�����0}��`�G������G�w9$�e|���hS�@�{Gs�xpBO��P��LƱG�d���E���������r���ӭ�,r���?�XL��<��<��q5���o�l¡9���>�6�#��W�u�{V�[AUTE�q�4C.��?q���6�S<���b������K�<�q4-f}��v8
ܧqz]3��F�l?:�jR}����!#X�bnЌ0/)�@�G��L���%S�"#8��q�Yι\��[:J:s�<9�e��ټ�C4I5_��e���\j[��FX�i�FjT�Y��#y��+~^8]�/�p���Ny@�jǲ�3����B���!�Q�i�ee�����4�4�o�p���
�l�'%�C1�3a��'�u ���o[�<F�u��V�\=��z�J�y� �8�2���l�����h;��[��Z��(牻���g4�L�1����x�8��Mz�wjϵOX됆)㸚�B��i����p��ƅ:GV^�Z�)�[�	�BI�ՙG�"�Џ��W5��ۖ�+�&��hʒ��B+.E/t�uW�뙿�����F��z
�㭻�N����9�<*�'�����b����=�NnE��;X;����H�k��,Ҙ�7����W��D�ώ!�;�����v"�h�@���}I���ga;�%[�&Qms��D�B+sk���>Zh!�sʭ�,��Y+V�^*���IR��0a���^��~�RK��]��TLf�d!a���8i�dŦ(7ņ�����j����RGہ�d""2���_���i1��h4�1�sq�y�}��J1�@8��y�#���S_;ȑ�ޡ^�mE�������;M}}GRIڮ���#4���3�`�u��7?���B5�8�z �8�;t�d������>@w)Ёj�b'K��(�� ��t�EƕSh��Q���8�����f@�M%���e�g�臭Si�j���wA���jvG<�_y��2s�Y2� �s���b~o�)8���>�Vb+���n������<o��c[��������n�Z�9Sg{6��r����)���Sw3���U��ה�=#��~Oc:��1�:@��z����~�S<$�#�{f�z��_�2����%k</�b��żȼ�Pw�y͢_���S|��(�m�LBu��k1�L�ޡq���w@s��y@Bp�_Q���E��/�
t�)G�'G�a�޹��b��� �z�_/���]�0�ޢ������d�����Ѷ[��i���NB,�F����ϣ���;0��i��޴ӓ�����o�o���o�ր���8|���&/���c?����-W��PŃ�l1ں�B���u>�u;� ?~݌�p�l�n]��d�� ��~�pB��V�@x�1��e�0q���� ��L�E����,����3qŦܔE���6@z�4�Z�'�}�}�x�lrW���͸ϭ�v
��߫�[���~���D�X�mz=�,�����N?���ۇ���]7���Q&&#|E��u{�֭h�/���<�~��º�u5�j˚��j�F��d|U�'V1���L���"8�ӹ�t;�8 �q�M�m��7����_Q&�p�pv��P �  ��(8}x	�:�Mm�	�����!���ӭ����( 1�k�B�nF�G�,���5��w
6]�,r8������KߍH3!�h�j3ب&����q��'_��©���"Q�4�b,����?����T�M
�	~^`�ӏ��=ߤ|��C���^ ���?n��z���FN�֩�q�j��q��כtg�P�MzE7�a����^ۤ�?����m��V��3Q?G����������d��p�y�`�N�W�1/5�. d���8���4c������A���8���������J���7�(������g�-ÉZ�A��&���5���f�M.3�PW	��3�X���Pv��/�=w��޸�%>���4�J&��y�u��*( ��Ք^Ql�Y�K(��lR�9�� �Z��D����P���i�UA�x5�;&���%��U��Ư�p�Y�95�MW14��f\��������F���ݳ�EF<tG�����_������C�Z��E:�) ���p2�s��6�,[ޒ�	2�R+A�3h�#����q�:��?f�l�?����g��{��CH��g�&����Ux�5�"��/Ǽ*����Qj;C���_lJߏ�sr���X���pG�q���r1���,�B1���9������������N�&�0�z��N���(1���5 ���OK� �]=bn��)K�@���^�ɒ�<p�Q�2�b�'��l,�z�=��\�YAU��E@�����٨���M��żp<<�Ŭ?D�t��/����8���O��'.�����(H>Aځ��4^Ba�����9n�!���Al�[lizf�Ň �0��v�T��g䱜��%�n�o�cŋ���ۦ�����ȥ��k'���!(f�c7�G"�煫�)�W.��%�R�N�z�!��~⁒v�0�Ka�:a�����Q:�YC��@�w�12NU�
d�c@��w,\'|=�8FƩ̘@�Yah/i���B�Ƞ�g!�f�l��$A@t;�T6w�vx��/���A����������3�۷�J�RX�8:^��z����g��b�=���L&��D��T��ڷ��r���~|�1���7�}3)�Ho���F|�0���������=�����������V�a��6�z�SZ���
E�� ��T�R�u�v���
=���j�Pü	7R��T���_��$K��%p��
|�'z]�B�/z<Guo�b
���~�B��H���Fɳ��B)iP�u�W
��)���6����"
��R��Z	���N6�	\Ǔ`����D�( �B����fb(��n� ����H_)��K�:��L��[%ζ+�q�����+i���p� m�T�¯S@���</K���?��\Iw���* �M�Y�Rxek�,�
��ƍJ֡����_@Mw��s�/���q��e�)y��UZ�
������G*TJ��[htl3�).s�DY{�FyʞZ��z�⿎��K1�䨸_EUʳ&�� t7s�:�^z�
,7Rbsc+y�V=��*��X�����{�By�K�� ��V���YB�|ٲ���\禎��"3�h���*s�w����l)�%�n=�ZJn��bōU��?��`CT��dx�م�,����je�<�=����j��m�'w=/W�"�y|V��Y ��uĀ��{xq�. �K����y����;��j.��Wr�k֟ |�#����W'��K��B�*��;+��)|���t�DO��8�Y�л��'H:��	�B�Wr����Іrz��J�T���������M!bN�
q��BWvb���ȥ!#�d$Tm��ć�H��D=n}^�M�u]����ɿv�_�ࢉ�X�+��t��?����~�      �      x������ � �      E   �
  x��Y�r7}����خ���%q��rʖ��U����J���IX�``��>�#�o�-�)��=� �"��h�~0%�֗�ݧ�n�>�i%��ZyaBmT�(d%^��)���a����o��p��q��g��iv|T?yW�k�7�;x��O�T��V���J]-�L�9�!i��/ba�[+j�.t-!����ǿ�ᩬv�g�OQk�[�J�S9!�R�tm`�TU*u�7�s���6�,}�"�V�^�B,iǍ�<i|�kX^��U(xY���A�ʳr	�卞�A�s0��WȩZ�ǲ1ҙ�Mn~�,��>��6�PW����N�*l���WޓJc;>�nv���퇌��,�ԝ�JMH0vi�r1w�i,cn������B������'B/�1! S�x)7�*����j«1�"~v�7����Fj#�������Q+�m%�9�6%�V�G]<k/����$�p��~e���0�bk�E_�����(@��(v�^�b	�0lZ 	�P*��vA5H����*d_Ϲ����qP8Ck	�V�i�%��fLX���@tz�`I}�����x��o��e�Sq�"IKYV&˩*��d26�x����t3�-�w-�&l��ڐBYb�p��9�
�a�?��7d{?ԙ�J����z��`vbM�W�"�`p��Z`�VU/H��I��b#���[�|�9?u��1������	�Ea�/5^�N���j�/mu'�;���r��}?���=�Z�ӫm� ��^H� ]m`�r*�a)�V�WR5� ���AX�#�ųѐkw��,�t�x)7$BO)�p3=��@T|i"����l ����b?�� �w����pȫ$3��4�2����V���E`��K'��w��خT���5Ht�׷�b��䘆SɜdK.���5p��#Ī��l���h�4Ar��,�)���Wq��E4��kŹY�	��� 0��Ȁ���tE(��akr9,D��.�I�dSS�+d_�P�*U��R��K�f=�eA~lA�#����6�U����Ů�=��@)��O�@������HoSN۱S�����΄�,UB��ܕ�It.��TRZo�2C"p�}���s�Ws+]904/�s�BR��h�F>�!G�Igب�o�v@y�����w��	�A�z�FxEIY9Rn� ��0�	Y֐&+ej���2�T�L�������h�(ٹ�2dU���m3��\�Aj�r�z����tŸj$h���`���`���刋��?��#��rG-m��[ �����x��6�Z�R���o��@C4$A�����S�BzM�D0�%��D��B�ݤ�9��ͷ�*6?��l�QK�L�����Յg�ȨB�1$J�o���a���CY@��ރߔW[��%f״	,B��L�k���T"
>�&*��-��!������,��E��v�x���d����'�����~3�	̽��Kw��,�E�D�g[�w�E���,�1ݖ��? �R4j�U1Հ�!��`'�∃������V�&�o�����̹�@	q1��8?��&�uuo�s=F<b���3�@zu�F�����Z�7um]q�[�݁3"�`a�?4q���ʜ0���[c�D��9���ڦ,���S��=&�yǐ<]�)��^0,陮����W��������Iie-�k�ޞ��QX�E<��e��x�$L1n
������p.�2�Mje　�r���$��o7�d�~c5/!ꄧ��	˱�T*I�[��j3�L|w�P���T9d�s9�
���&>5&4����;�zj�����^��r�׀ۘJ��	5$�U���N�=�O��Q�M&@������C8`���J�Ñ��G���ZR�x��ub@��*�g��A�گȿ� d�qr�ԫ����ou�����\�u<Ӂ�����Jo3a6|;ȋlVW�A\i٬E��Q����bQ<!$	1k̈́f���[�V���nIi�����!�/���ٔ�]��-!N@? _-X�~�Ȕ�A���d�#ʩ0��0	��%҅.H%fA���$�~��O'�|�ۜ�T�	������Q�i5/#:���)�}94b[�/���Σ�i�p+�kn�s��U.�ӏg��m3O��nj�X58e���M?_������эl�8�^/�[ӌy��ֻ��$p�ub�\A;	<�_����(�Gi�"A�V~(W�@j���}�q2Γz�(��<�h�#�0q}Dg��x�LL�H��}=�s����A��W�	�I7���ρk���:o�4�ZR�C�I���G�v�
.#�$3 t�E���Zت)S��"PigZcd�1Mߢ�a^`9�� *E-w�v�����5$k\��1����n���>4�F���>B:���,�)��<����~�4�z�6ܐ;�@̡�ōnI��o�;/��AvM.�"W�
��Ø�� ���5�
��ƛ�4�B�NE}P1����k��K�u� *DÝ����p����aP�+�h�z��`�γn������y�9�sG~���:�����`LkΤ=�#��d��o�^�ė3#Y��h��:�|r�7#]���V��\Q�3��j$&�:x�R�Y��k.� P��S(&�
0��K=0�9��q�c��_���G(c�w�۷o��D'�      �   �   x�=��n�0�g�)��Q�6���!Y��K�b�,Ht��+7@���;:pw��"���EuG��?X��[�:OI
�`�A��LoѤ�l:D�'؍ņ^� >ç4tL/������,}
lB�\������m�Z�D����Dm����VJA���Ú�=k�2�4dC��y��o�����[�G��~�č��떰����W���U�f4j���JR������\(      �      x������ � �      �   �  x��Ko�@�����C�^�Di�RK-E�P$���N��]���P�3�W�G��@5'�f�;����E\��9�Q�d�2g�-ps��4��0����G`����!�A��6Xk�`.,��+���Y�X��h��K��L��U�.<�~Sm�CǄ��;�CeT�5����wNĢr:z8?�9��5$
��W�g�1n���Z(X �d��n�~㒪j�񊙪��\/�1� SPYoZC���VZq4�:��0)�mi%�����T��s�2xtYj�n2�Z)��W�v[�3*}ɤg�D����Th/y�
�&�7/�@ڀB� �VX�T�PJda�(af���QVo��u�h��t����=T]��~̦��fΔ�Q�x��d�V�YA#�r�4�h�1��Bz }+�#�Z��a��*���fd�\+|w^�O)ң+G��U�0S=��.�6԰��90ZB���z���uXڒ��p���PH�w��ib�!>�o�ƚIQ�����R�m���}�w��%��h���F�7�Qɘ��k^�*���x��s���7����ε� �ּ{k�Po-��Ї�z�/���	�]QYз�9,N���ȷ�_�/�w
�ԲV09�mhz�1��o8�O�ZV/�M:����qOq�\�2      9   �   x�%�ˑ�0D�u�_Y���c��X*����U�7���t��~�tϬ�3*��(������p�2�!�|gi�iD���œ=q/?��%|��A*��F.�I#C�ɦ�s$+HV,��X!{�+�Ͳ+�(V\Q�8/Yq�0�c;=�1�;c��OD�4�      �   �   x�m�;� �����@. >�6����Wpp
vR�K{���1��ג(P�:.%��,�5�E-�n\ QID�{
�n��23=��fW@��(9�{��J%&l4R:[5�J?��q����?�Q�.����TW<5�w^��.ނ1�ϫ5E      c   �   x����0Eg�+21V�73*�� ��Ť��d�|?�v�9���=L�.�o.�380��#�9�+��˃EƉ�Թ8%��zM'���*I9t��SV\����p^�b0.��ٌ%���lNC!u�vZ�$�ʹ�g���_3�      �      x������ � �      �      x������ � �      A      x��iw�ؒ.�9�W�K����k�z[��]�8v�ɑ�]����0�_��-r��̤���de�%d�;"��������_]9��qye������� ���]cp@ };@ �)�&�	��>��;����|(?�e9]\��e�S,��0�O�Aٌ'�?F�(��r9md���P�����_�=������Pz�C ¶�޷��ps[��w��<�'"o����ͽ�3����ɸ쿔����Þ�������r�g��tp�H�����A��@�~ }2����wo�T�c(I#FD��1��(aC��]���yOݵax�a��0H�G����Ga����?7��>�%ᦗ��?��p��Q�1��
���x����>Ȼ�>7W�Ê�/�=ޏAC����W_�w��_�����z�,��i�W�3u��Ѱ� ��t�)�N�|f��sg�ם��i�'��} T�Q��X��@C �o>�1��� 3�M ��?��+wn:�`�I5 ��۠B���@��M�E�kH��� �cMN��������}����>��EƊq�Qb�a��I��~�g�7�I*�%�����%�I2��>B�j� ~�  �F��&F�T{,
�u����%��=l" -����,De+p6j�����o]���=6OG��=&�<��F)�H�C[̲��L�t�;�E�0�˄�&$����L��P+y�V�o�k���4${%S�\��^�G^n�lZ6����s[ʇ�)d�R.&�yܿ�n�
�^�J���.> ΏX�"�l��P�d�,��I��`�������4�� Q �5zo� �V��&@��*���V�E��n�e��Z�q��t�~zЋ`���FEh(u���[t|�l��lú���T��w��Ϡ@��ު/��'j�b������c��zԙ�B|�r��zGR=���[��C�z�y�f��0Yf�i�E�~~��H���,��d���~��t�KM�8;�_2�iC�#�q$w�P?��]��G�SQk���<�L���⦔|�Ib��^��rV$Jh�K:<����>���j�/���{�����Zܶ��i��������oܽ/ԍa�7<���/�w�n�b�5�ǳ��d+���ݲv��;���Zџw>o�3�Z�k����Z � J7P���� ��-�`2_��~��{#9%��/��� ��M�W�t��9Iw�qDҝb��������/rau�q4z��(E�v;[_nR��������o�(�QRq��rR6�Xiy�y�O�o?�0p����Y9)�10� �	�p�^I���<�t$�<C1LY`�J��ŷ�իH�M������C��H҄�ɫ�E��{1Ţ���"�e`��>�E��D/-��.�u �0g�i"�|PJ�������P�S�����D�Q�C{,�6��5���1SCZ��������W�(0��`�K�&g�me��b�Y�<��� 6��D,G���ɷ'��	�5�R�=�\cv�i����d��dϫF9��͋:�L�l�aB��,���h<G�!}����Y�*�|Cuw�����5)�6%{kR�-+B�O�m
��>ȷ�x��k����"B�~���=wR�GP���=��4�F������{���i76���:NG圌��7Y�^�r��G9��>��������|`���Y����/}|e2e_��7�\\�tzIsr*� 
rf�&ʜ2s�O ��[�i���D>��v���H[�[�?�5P�@'ӄ%��kO��gP�OP������4�Y	I�/��U�	C"F�p�F(9��K����R�u���ڂ���
�q�F�cJA���TI�c��{��U�*T(�j9U�F��g�3\\��M�P�I��o�$RzP��%� T7��W�V�L��_���[�!b��t	��ݦK�5�MJ���V���[y��4j+U����BI^p�d��Y�����o��V�D�J�_(W�k��H��2�+�ä�.]����a22GBL��!-� &C9�E�n$ ��J�a
J��R��ow�r=l�t�i��-�!���t��6�3�'�Š[С�ǿ#�����k@�)hrr<r9�BeuXX}��:UA����X��Ͽ��I?�4ƽB�G�9_��S8���<즽���~|t�5>��C�{>�^�@���,BDxg@�|6l�9��I�{?j�'ef�gq�(��s�������Ϟ��́x�u�X�C�?V�Ue�^��r9�������L�S����	JW��f�18s�!��X� [DB�j�F����.�J�Dq� ����"��2s��e��oit㕭�q������Ⳓ��7&��I6�	���\�>Ҥg�m�D��i���
�My��-f8��D��A��	�![ׅ��I�@�L�3k.����F��ubά����� �IPT�99>/�F�I���K_�6��y��S�9��r:-$[(/����p�s��;��K�ʻ,�	�ǭ����]_��W���,;��rz��z�w��eN:���֟�Þ��B��S'�ovG���.�TP�J��s��m��-�3��VI�O�����2���x�h�m����]Dg ��" �7�P��b�@��R�c�Ͼn��3F��Uo�Ƚ,�T6��l�e�7Ƀc5�5�7h�T��ă����O�h������5������������_��W��) �4%� �i��H�:���Lb$0mj�ژY���G&�;9�D�KP�T������[�5ܱX�~r	�����pm����6@]z�{uX�i~�i��������"n�y��m�:��Ta��[�?/�޲�+�T|�Weg����i{������0 �� 7DG�7���X���l�'���|�!�Y���n��?:��a����1���l��+5���d�LI�=v(a6�']�6	w�p���|X�.׃=�Sb�{��^�����[�zU"X�ߵz��D��נ� �.�#��>����.��ˁm��������~�w�ǋ���T���л\�62D�#N@���E���Z7�kߖj�_t�w�&D�A�и��	x��<�C��Y!ﳌ5���2c@��@�Jd�6w�4 �k��.mô��S]����f��m6K\~�D����٬,ʼ�i�o�RI拮��l��Ղ�m�a༄��4D��/�KcBm6k^��:���h�i��a�p6 b�Ő��aD� �s� F��p�4#�lrj��PҤ�����2si��-3B֤Ya����;�V]m���Q ���~�ٟFj��~t����xz�w�f�M���G�����$�\�Ɠm�8.'�DY��:9� )	��@�m&wĬ��;HTŉ�b�?��)X�7a���_ɂ_(-�z�����P�v#�~X���7T��>�w%�4b�h� 8�4��u�
��.G�Y�6-5�z�\�s�dƽ+㟷W��d�q��7��G�EWP�7\�����@%J)	n	D����l���e��F\72�V@�E��1eV+�o�Y:���o{�j{KA����U]��n�oJ���6���l���	7��S�n���-�d�A���w�V;N��n���y�=�0bd@Gb1��r@������n�v- $js�,-��F�5���m�69����ͧ<*nA�~R���f���Z��S&�<��= o���0�	���/�p�-����`�5(�0����&c��%�e��LbOu�2	z:��(,niK׳g��j(l��`�j���U�aU z��JO��6EY�Vml?U�.zp{�|�ug,�b�J]��d:ad��8���d��u�I���+���l�kk�-K�ס60(q%��&B��,B�sry +���Q��pB�;{�&�)ޕ�����/q�����p��Nuz�,8%�<��ьʡD��\�������*�@b#���&O�ݣ���M�%O�ycUL���KG���K��{â�N��d��tr�=�    ��{<�]=by����]���6���n�y�O�&���yfE����x�ΗJCu�����ѯ�#o*w��{�ŋF�͋�2[��b��l���Yo4�N�H3��3p�=���i�-��}_�kJ�����[I�7�ɺ�:�|&z N�h��vɰ/�i����!�;�������d����척� ���RxG�`�ΤQ.��f��'^�+����+g��`K�F�2X�	a㸳�Lm�7� O���:��: TS�����k��6d������nsͨ��:m6[J�tI>�K�<E��sQ$��Ao���k��� ���&����>�.��%��������D.��_K�����.��%����&�7����Bs">`��^᭣*x��	�n��V%�Qf8����^����3�L� O��B*ȮK�[4M�̡@!EK:&��r�Z%��S��M��%�(��7�'#��X7�un߳�n���du߾+|�@�V��~q7��2�璧[�,�E���z=�a�<�������=��Z�!�)jb�O%>��y�^ֲò�2u�
?�o����mr��TY�<\:�kk>G�|��S�1�1T��p͇+��\R�md�H!9��-L W�B"k��`> �&���49U<f��XD����-]�B�$��I���UdGy�N6��Zɬ���J2�GY9�X
%e�Ur���� �ĵl�:�!QVU�v]�XU�Ԉ%�W�T@������/�ic�O��|08�u|�:�?����o<{�IC��SG�`@P �A�¸aa@l�l���q� L(����:&:�v~���*BG��`J���x:����<�#�c�#ǘ	����b�z�g�Ȍ.�p8�w���	���wV��w��_�\g{�2ｩ�q����\��iv�~����$Or��r!&4�GJ��@��k�n����Qv7x~9���"/q�_����>\�(�Ga��Q��g��AS��k�λ; l߮};/� ʵ@G
����C^��Ϝ��qK����WG1����SօP:�9G���� ��4]�nR�H a�Q�;���H����E���y�y����^�|�a���UU�ݾܷ�ܻ�������F٨�7O��uf�:��eO���`	���麀`.H�g(�M���O�cp�)Ĉ)��iX�l�״�����*.z���9�R�߾U���PsF��^&Zu�ڑZO_����ڷ�D�L"|��+ѓa2,��N�鮴:����;Z¿t�`���&���O#���v�^��ꦗk��
��}�}��:�j���>�����yX�=�JJ��\*1YO��%cJ�0�k���]�e�
U��ճ���%�����^u��
B)ou�gi���W��d wf�QEڮ��h�_��L'��_���rX����%M�4QWο��T?J�o�Qݹ��D���'��t�mv�z�S���*j,SIU:�D�����Gy��y5��f��w`z8���)K�21����7E*{mʈ�T8N�m�A(��#"�6"�s��6"Bٖ����H�'�u��6����t�)+�R�Y��G��v��u�GED�Έ��k����F�+�yZՎ����6"�DD~1"�(�z~�DD~%"�8>&^�#P��WkZ"��;���&-'׻��YF���.J}�-H�Ö"�y�g	_(�{���=Tշ����'��$�-�����B��G��H-�ו�~5��&�'�qZ���E��G��p�V#3u��g���/�"TKl�(�|^����!||���kɨ��F�p2%y����s�������j�ŞA�kj����>�n�f�����~��w(�:v�3W\)eC��Č""	64N��P��a�i"hs��5�0�IM���&��dE/�P���P����=��ua�5�M��r*�|m���0�*�
�4������lO	�G};J�Z{
_]���6pi�O79i���1���� �k���4mdb�m�`�Uj��a)�qo�{;�}�1��􂤌ڷ���ٙ?�F�mʰ����SO�e�Y���$Ss�?q���Z� �L!,ȩM,����
�S ��1G�� �| ����i���!Sw/��ҋI�?��!��A'�IR���x6�#H�x���d��C�_lC�J�]B��Ȏo��>�K��׊�D}���`�k=\6�;�Ο�+�P5���T���=>��O�}0��C�'�?�_��v���,��;e�6��Գ�J%��`�-�$B�%�Dp� �,��F����*D�R�'�6�����&*�RI"���v�᭖Z���������ҿ_B��3��F�;�j�`���q�}�e��x'�E����۰��O�y�쌮�s>=���$;p]� �m�܊�ؔ�am�	�@�8V�����[�tnE�ݓ5E"�$���S������;=��C���ͭ�
n�����6{�ň�2�o�T��9���LH�$r���zw��B5�����޹�z|or�������mw��귂����2w�\ӕ�q�
������{م+�>��|D�唍�´�kR��ÑJ]LH))Î�L�@	�H�؛���8��:��f0o�Go�
�e����y�S[�MV�i�U��s��g�swW^aY��]���i�����\j �:Hi���L�VGʥq���'ɾ��(h
|2r/�w�����һ�GQ�h��(�B�Lٿ,�J���F�y^���<�L 0V�Z��r�v�W�����p�0�e�Mr:��p��p`�j�P��z��L�[��t�:�hl<;/�M���,$��X=dc#�����eߞ-�)�Ƌ��P��fBM�	u2�����I�����KsV�%i��Y�z�͸��|q�	uw���1xiPd�n���r�&�%l��4���ٳ�SE��o�}�a�-0,襫�W�.������<�D��-�.�a��t�,��uc!��FϓF/���Q*J�f0��Dg^dBL�eO>��<M��xWYx]��P������H�RG�UbM�����Q���GA�RVGm�O���g�VɿQ��qPd��}��MZ��U:;���� Kz��C7rd��8�2�eH�2�"�`CHnJ�U����$����j��o_�����O'�˼$`Tf�X���Q����7}#H�Ul�wД�m��%�u�?!߅XM�-�Y�%�Qe����a�X�����P�|�+�C�1*O+��͆4���z���Ӌ���qWG�qO�c�e�&�&��㸶I5 1L�p%D�PH^X�c@��B
�a��0a�km�@����o���j�X�^��<O��{g�v3a�6�h��˗���l<�E9���:؏+<�v��fE��H� ��9?Kp� ge�t�m]��I3�({*�WZJ�T������*��?d%TI���,=��#ǔU6Ѥ�A�eC.��T�p%v�6'�ŀ.�V�T����n�5X�}�M�*�B��]�or錸��h��S�xl�xJ�,������Ǻ�`�a��)��I�Ug����0�c� ���a+G�v] ��>�������F�$���/F�>�o���������}��W(��4�?{��a�&DOkϾ-[����xT^Dez�]N��y��̙w^Y����
��Baxʲ�SL�#꠰A��J�@�C	�6]aW��`bh�u���Jp��/z�	(��<��i�Q�5%�������--gx�]22K���|�x<Γ7���0���I�\QS��� �>{���}��d��B��x>�i�¬3X`6$��8K�]�����S�3�������1t���3�k%�	~�2�0�˼�{�����R���JI
Ҕca��@(�"����E���� ꔃ,���Y��BZ�AjZ9D�(�5L��	��v��v�0���cFeS��=�n<����a��w`��tޟp��#�� ݽ��^��MG��^���Ӵ��r�{�5e�{��5gчe��Zִb�5�ǳ��d�s(����    �L"R���0X{������.�<;�~X���Nj�	�C��;��D�U���$�9SK{ʌ��J���6�Q��^��Pw��n�B3���SF���7ʿ��ή4��.�L���/��$��Ɏ�:j&\�����tu5�K���DZ4QX��-oKB��n��(Ao�˽,yQ6��h��(���0���&�#�`k�wC��n��@��plRp�~2ϾK�]��A��n�!{�'���E7��JnG~�)��3s��E
�V
�<ɒ$yΒ��횳w�������Z�]���W� b�d���6^:���ɖg�(�������bЭ�Oʵ=fC�Q�jC�kJ�B���h��V���͎�V�a���k��R��i�+�Һ93�s����ټ?/ךk��wm���w���aS]��=�f��Y<��d�4����!ֵ��%�����!�[3�p)���. M�� ]2�����oB����$C�>bc����M�o��{����*^R!�N^��4p�y,� W��jo��{��v��>�6ދP���k���H��Μn]�/���5���U�r�tt��&i��Z�4��� �BWHԐ��R�.��� lg
�k�^\�����Re�K������-!�G+���(��.���Z^= �"�u�����Sʦ��t�d���Ґ�!\��\�H�\8�P�&�Byj{E�HG�&?@�Z稝�Z�ˍ��c���X58Y;y�-8������5V(��M���y/n�,:���P��i���c��E1,e)է+&< �L^ٝ���W�v(#��>�c�r ��; �d9\��� u��L����.j�3Ͽ���~W�g��캕��x�T�|o�:n ���(lRA�˽�_�<�7f=}�0N��u�b���cJ���λ���V�q����}�ě���!�S���}r�����}vf�F�<66�uڲ;G���4�M�y�&�Y,>L��4KG�p��_�!�����r}���5DMz�a懃鞦傑£����؏��*�f�g,�`e�IԾ��wA�ϱ�<�i�����i���F5�6�u�o?G	T�X��n�OC�$c�)#�5w����m��~P��n�gi�٣Qd�d��P*>�;ݫr�d���d��К@����/C�b����j f>��%�K��Xc��{[Q�2����U7�|g���K���~��t@E��~��uj�A韄D7J7e��.}f��mO�&͉M,SS^���I\���X�dDZ��r	�W.-G ��	�������/'٢��/�x�G_�	��[�|ƨd���g�Y><j���=�r�5_׋Q8B��zQmK���d�ҷ�u��	���c���C<��ff��L�M���d�Q�y1}��W���玗�/n�:"ߍ�R��H?�E���P���ُ���Pڔx�Z��f�[�J�y�z�k]���5���
e���n����EvH���tRv4�ѵ��
�Lv�vP<p��Ѐ�y�eU�}:2�P�i߄8n5�HEQ&� ��~ֺ�^�,_����E�D<<�s�dݹ���q�WұK4�aѨ+Dd��QQu`;��,XM&�E��Ҙ��Y�n�e���d����tד��#
��I���~ǝ�\S���@,������f�i$���<I�Tv:�<�����.¾�*�z}EvV�V���7�l?�C�*�=�,1؜qx�$?�#-&�R���� GBI�%�^u��nO�����j\M��s�N�/0}����Vӫ��;��'�ɢ�׸����m�@��Soݗ��D5�ѸjA{��F�	O�����M�,)#�W�U���B�����S�Gz�Q�q��?��¹l���y����`�3�5jS��}@FKʶ����+�L��YT<����-]HQ��� ���"l?~N�<f^��0�s�����(˗��`��rqܤ�β7�h���[��֪�.��Ջ1
OQ�6���(�-�����w=n6H^�)ì��v/�Q�F�s�oe����~�,�{�a�k����3�`�K�A
W��bB;�!ȹk��C	6,�QȚ�Ǡ�~_���]��}2k�ұ�v�閝�}�%�q��t&
�M˾�� �z��Y	�م�{��g����������!�H�t�ja�%!n�d2
��m�\�����0�N0�G;�+��� ٤<�Ր������j?)����ʪ>l*7�핾Pώ�o�Faq!Q�L��<%� �%l���Az�͔}��bB2I�)\ۆjA85�ɱN��#8����g��R_A�����7h�ƺ��9���A�� ��22� *byL;8�����ä
�I��/�BM!�*R4y~�����ӂ����9��Q\&`�t��W}M���o�����)�j
,.��ZM�\�ֽK5�/TS�?�u�T��ےa�@���\��1X�C�B�����a~f1�y �\��-� �/�Ű1XϮ-�1��l�m�u݈;�Q��$W�{��D\�^���gd>�czC8�4��>yc.i=	'��qH���^�&}�~���aӪ��[�QZEAo��4��ǧ!ge��/�~q���R87��5�m�0��8<e���2B\�z��! �2�%A�q2$7\uh�&s>
\�ަ���P�p���t5������UĚp{:�<�X��)oq�-�&R�{��h�Ԥ�q�A�������6���,���"�1��%��iCl|T��Q}��z�V����u�cW8V઒d*�)��Q��Z��R���|��������SO�bfދ㼄�O����^����>��xˤ�yIO��lR�+osrPiJa���mJd�t��ǁ	 �L��j�ndg��6N��7�<Y.�GO/Jkn��S���Z�7Okm�^Յz Ҿ~f���rYg'�:�V��xʁI�p"�Uu3 �\ɰpl,�L;���0�	��凟g���)�9��������񴟖 �1/'b9���Q��ږ���%@��0�*y����ɚ���S�o7z�t<�ȱ��($�R>He�PG�"�"{t^E�g��t_¬�'����/���v�E<ܗ l
�iP�wlbHi��Ԇ&ǈ~T���]��QE��z� �'2�)�"���ed?��5�5��Z��
w�
��������)���N4�i.���u<��"[�u!
NJ��0 D��#�(w�u�=��ؿ�N0��8�V�W��3]�c�����۾��=�L!2�U�o�ȱ~�q,��M�׀7����w�d�;�z$�������OȂc?�0��0sJ�+GO��Q�kl�<�窆$�����e��j����l�]��S�F&R?u��7A�e�vW*#N�!\�� U�K=X��TB�@��=s�D��`��3��i��ųG�����j��� �oY�*s*Lv�
��UK��ED�����������������E.S��!1L�b�lꚀ.�&��<����6 54dM���ϟ��l3�n�"
���NFv�)�Lu���辭G�7>a/�D�j� �86 N�>
A:��K�\�J21��q�a�X�vlnQ��zLH��i	��a���ӅdO�p3ʴ��Z�t"�x��kP�lb �Q�Ծ00և�V�BZ���ܴq��a)	l���mfr��"�RL��+�Ɉ.�:̽��p�Z���O�&��(P�O���"=���gVLF$��q�ǕO�.�����ÇY��v�2L���',�n��d�N%Xf�(:�#��T�ңnm7m�����Y�A.B�tr!R���K�<}���4z�b��nί��ƙ5�r��Ɲ��p�����1���r �l'd8��O�Q;:y]������j�Ȯ�i�Õ�!�����������<�:���v�~p[����tJ�F!��\�ÑY�� �H��،Z�YqpX����fZ.��8B��kY̱��|���q��%��r��Un1�MAO�.�э��A�+^�.R�n���T-dRF�'�n7�{n��jK?;��y�i%���7HN?�ބ6PKHq8o+d���6!¶-�@u�I1��"�ష    A�;I���ð��Q�B-�:���t���6M�T�/�F<��Y��!��r�����<�y�CП����_�������=���/��JR�֦����}k*@_�
~����N"��T�+����.���ﺨ�ХT�52L�F�;�Šꢚ����xX�X*LGI^(��,����j����i�09p�U�~<�_뱵�I�~����Ǔncڝ,�YG�F�L,��ـu���y�Ѣ�$ɷ[����o|�_�8���w��m��)-SVć��&��I9�HX<�0p����i�3m�f����sP��:w^L���T��g�iK��n���y�=��\`
�*�8\�K��&&5L�
L״��l�I�(w������k�w��\�(�k�|^5��h�l^�/��'L$��Ax�͔7�yE}s�l	XM�9��w7l���tM ���0�T���0��eDϓ	�|s�2?�mbO��P�}�Iw��j;������[Ȼ�j���Đ��Ė�-�1-��Bha$���0�&���Ə7�Cݾ�Y\Fz��~i���o�"��pj�,j;H��K�e�0����hPN���F�Jh)QtLJ�����;�����jXV�J���!���lbr�)�����x�3n�@=���B�ㄑ���M�7=�ܮ[��MO?GqDn]���A,�,��&%�՛0��c�n@�ajQ�CfG�0�þj����%zK��UG��5	����������l$'\%Ƕ�0�����æ����erb���DҴ,��4�*�C��v��h"��ٲ�:�x����#I?5Q߯��~�%���K Z/j [���RVUs��h(��!o�e���0�\:)�N=~�l�u#��F7UW����VZ�d�0���p8Y� �'.���zi�&�.�=�/�9T+�t����R�8˰��i��)�K!��+��F#osWx��6�%U��]~��VKzj8���kp���l-V J�ۖ�$̤�Z� ���������H�]=��b|�jf�����Q��Ic؝��������I�}��wU�S�ϋ`2�Rޙ�&��)�|չ"�G��6����"��F�I��(�wغy�e��#�J�?mt�ܿ�-�l��퇍����VXԺ��E�q��U ո��� n+sGl�V���C%r1�>r�j�X��$	�H�)�Ն��t�5Q���u��V'p`%��T�D��+}�Ӱ/^�����:(�ay�[�̲�p�i���4ɳ,?}��.4�C��L�.�.&Æ��W�d�e� ��(���W�~!�Ax���dR���<]k�g��e;�*IH;�Js*my��9)-�q6-;Rnԧ�"�u2y�d�P�d���sX&	S�1��E�D���3j9�~d�p�%�{&<B��9	�2�8څ�-��I�������!�D��8L��1�FI_^v�y�cb��bQ 0�8V����R�h�����C�|_�=��&���?�?�����h�� GKs�'m&+/��"��`۷��E7��P��`��,�/;���)�5�@�6�/���\��0�ˣ�*xE���3]�#hW�Q� ʍM�ٻ����<�!���~W��q}�ʽ1z@�����u
�5)��h���`���y ~ᕡ�-t�L��Jְg���|�+]<�ew��up~+��1�(K��|pr�k;�f�Ď���^_Ρ+�LB��h�1f��؀9�I5��Z�([��T=�M�O�,��~�QӰi�)���������#;V�$���J�� �4�a�uqڏ��^�a~J�l2����u�$Q�s���@�T]�ණD��{t$l ����}b ��3E	n
��&#Y.�Fo�g�ަv��͂�ۼ�*;�~�x7&�y?Q��E)���-�9��+{D�AP5>�(���|$�Mt:>�p������QnG��!,�B=J�9*�,�av"�!Q�x�QTOVg���y��z�5���\�
�~��y
lH,) c���rglb+}@mH	3u�	`�4%�uư��k��wuƈ)H�NU���M�J�P3�eɗ:c�2���$��8+��s/K�&��g]���N���A���q\L�em����r��DX)S�p!U JW$�ڊD|�"!y���,�=zЖ�q�n���H-�F�����Q��6�p�tI_��Z��_��0J6��cMW:����R�8�e����� �C����Zӫ�U2X��oCT�0������,�5�cL��!��G;?FU�������9��FS�.�eQ�ٷ�ߨ�p��h�o?!T����e��r0��E�r6.����+?��19��`q`�:�^5b.����%(�q`	n�+�l�<�Z�p0hJy2-��eX׈{��\k�p��T�jd'�k��ی2/s/�m�� ꜇S�%q9!�8u΃B�X3�ZcJ�)-$mlf �
j��`	(�f��<@���<Q;���d�\�wմ��aP�r�{kZ�[زP�~T�Ӂ��s�����mb:��s\4MK�X}� &�6��K�)�#��v73|֑�)O�șy�r����nX��Gi529��фk~�
��h/�X'���0B�`K�ZO�1��$&
�"���c��f�I l����jW1!'C������]�L֔%Hݪ��E���(&ׄ4�xO���,<�O:Ƥ�K�o=!�S�
GUhTsM"i�ɖ���n.�XS*nk�C������8\*�t�4��u) �R�Pz�I�r&57�X�{��|:.5I�{��RNr��|8�2c1��%��(nF��vr�U_�@�뷆����ֆ^�Sz����i�,8.��Wnm�U_�P��z����5fy[T�u��m�	�x�j�i���n�i3�0�Y҅4A�3�'���3����v���kQVC"*����o��v�HS����k�����/~�af��-�7fv$�0�KO�=fѰ��e��b`�A&��P��N��y&��H�y�b�
��$���o�W�,2��:�q�p� "IF&����}����4�

1J:���:.s�/p'�!!�J��衜�a!tQ�p)��D���t���r=<P?st����F�Rl�v\W&4�8�Z���r;K0��� ׳�뻊�b��u�T�[��I<��W��I����o�l��:ojm(��3��;�?�q����������(���BT���H��&�C�u� X`te��X�B�#�L� �?����wv[�n9_|�`��E�A��`�hmLD�[\�ݾ��CD��-���o|P��L{��7�^��{�|:V�e%R����q���l��v��:u�;���+��#`5O?M���p��=i��|]�{<�TK�.�T��z ����@̗�T'����M���Py��&*t}��ܪ�UA�2*�ܳse	R��ĵB~��!$G�6���� Ȇ&�Ф�wE�P2���9C�3X]�������aS�.�룻�e��F����Ho���F��Lؙ�FAT���� k���7�2z��N�0b�ƶ˱�	5"�����r@�����l��<�F��d���*���0x*#�y�:n�4#m���с�^����R�Y+���/�Ć�E�צ,����S�K��[�zl%!��Z�bح�$�9�%:]̀�P���N�Pgôn܄/ji^��T�P'f�%�/>������j����YdXa���,�Me�95�ip�`7�`��#Ö֒�Ħ�M��eWa��$g�;􊧗H�h|0�enz�����El��@y�7���Ւ���˸Rt�NK�ўL�Z7�2��"�4WRӁ�Z�yW�y8�Z�&E'㚋�ڃLs����iR�p����;c��+��|���:�.C���NK���A���iI�́��.mY�
�Ι%-[p���.�;���w#c���m;��]B��9��,�I���M�:��I�/ƓH`�\��x���N���A��|5$�{L"�&�S|�.�_nBT�G~u��r߷�7���4o�S�zݑX�&`1�H�b `G��Dg�����7    w�jEżv0ｹ�������/�~>[56=�"��p�X����N�x��?�k�zw`n���kJсQ��g�$��f!�l� �)����ټ_�ޠ��ߟ���rY�������~	gᏬ->ať��R[l�ɑ�t�u���ڑ��O�c��4��y�v�=��T�/�̻+ȴ�Z߉S96�|�D<�'�ZHi�??s3��O�7�x�2�D�-֣��J[� ���9�謰zMzӄ��d�E2#�'S/r�)�\�i.z ��!e�)��2�����'�g�.i8~�6���DݨA[�biAI�%��"�!�+�Ä�@��j8���Y�_q%MNG�$/~fl� TV-��^��"_��z��3o�ۗ��z\���u���$�P��.��!�P�@f��@���=���X㭗�N��/E��kκ㹘ݤ�Γec����2�u�)��Aw
,�h9��z�G9���`�5_O4B�si�e�4�?�i�lOG���Lu�8���2��	ܷ�L�=-�AS"�»d�jy��k�$=%� r�G5{��&����&�$�!�0-���V\-��&�W�ѿy��bhx?�W���%J�N�eZ^4z�h�W��t/�jq�<��C��J8��E)N�x:���$]�گ�����{��~%aMr�Zp�����G�e�Q��j�yX�jF�F��8$n�B�/�~�.���^�U��)Q��Տ�u���:�0��Z�P��6���z���2Z�.�/�`Ҕ�d3^�Y)�۴�����Q�X��@�x�fx7���Z���Ud{�b���o��Kɡ��[�v�I � saC"@W�e�[��v�u��;#u߄�5%�'�v�yZ�Y/��Q�Wc��Xa��/S���~��g��ef�1���ԩi�PL�02˕�c)��$�ҥ qM���G&#lݽ����BYU_N�9�m��iӲ���ib�MB�и����>�
y�D��7����o��r�͐�j��dI�r!bJ�jPnZ���2�b����c5�ɦ��'ʍ�"E�e�n��W���j���lxd?A���\Iz����bzu����D��P1�kky���z��Ԑ�ҖFU�W��⑻����������MX(��~���C���l���,[�Ê0*�LiNxі���I]<�<k��eV�`��@B�z�k�1U"�`�T G��G�衦��t������a�5�G�#��K#�%�Fw����g�_&b6+'��eY�K2��ٓ����Z˩�n����e���s������4���o?m�ln���UXx�g���~�E\5���iݎd�� ����v�E�0�m�-	Dp��ζaBL�G�u͏��щo��:*�﨑���Wc{8u�OGX��������:q�M��%���n`Fэ�4����-.��W�j6 9��f!)����б]�*m�Ӥw�m0CB.�������J0w�|�?ES��"*��~�a�+��*O�7zv��l�27�3g��¿	/��Z�t��rF�-�\T7Z�l���@maR�|���0�f[䤾��@��*���	���-��p�XF�W��{mU��S�&�<���Ë��P5ׇ�ڿ!�G	�����q\�e��2���sK2���\[ҏ�i�!��'F��!��V�L���fΊ�%8j{0�R�v��[?H�}0E�S���&r*B���?/��v$��$1I?���~>��R"G��əmȕ�l3����H�]D�͉c1@�#�@�aX�"M�OVV��ڪus�u�����YI��#��2�>e��D��;�6Ʌ���0����R �6�ꀜm J,�؈��Q�Q`ǥ�iC�ᮮ�=<���VVS������7�ʞ�`򺚆cf��c�1ű�@��&;��l�~��h��V�l�Tsc�����GJ���5�r?�IԾK/�Y'��:�yJ�4 Hq��s�#26�r$��H��A��0�)g�dI����Π�t΁#����c�Tʷ=�����-���~TN��Ƚh�Z�,k��9@7K�<��T�~%BĐ�4m��QJ:ʔCy�P��*��Ҭ/Mr�9Q`fQ�������*NTH���t�.NDTk����w�0kBwu�S6����I^�%������M�`u̵�G]O����f�$������i��)�?���k��1[L��S��731���,��~��,H��#��d �c�b"�2�49b��tc�l�$�TϞ�mu7l"v2$�o�M����ѣ��FB
�h��a�J��	��+xN��T.��uY��N�k�m	(�	Q�%���@lac�(�.��:�~p���{��9^�+����=l����NP����몄1���.���7O.�Z�Du��)�d�(W�=,���u���6��nD�EP��.��%;��moR� 蔬D�C��anre�sT�zԪV�� ��0+o���.՜�����:�D�L���MX;�!�pۆ�F��1� [J����n��kqݻ���f��-
�[�
t|;X+���I�@��^� ��\y7�YF�8�:tJ}�:��u8Ȳ�{j�"�W��R!�b�u@SS����X��<ݐ�(p�~��Ѱ���K5d[� Q:4T?�ž�(04E��%�Y�/u��):2��� u�%7;1lÖDS�c�`%�&��#���m��;����_�+ɦ���o�kW�NcRt�t���F�I����.ʬ23ܑC������v�5�/��u�2�Y~5@�m��W�z���69������@2����W��פ��;�qP�G�jߤ�tN���=;!���L������PN�:ԕ��P���y��U[?��V�\O�e��鍜2�A���m�m%�}���/��_�O��r/�-�l�:x�S��;�WY6��W���fԪ�*L	�̙�2�K�'�f,��Rx�q��u!�\��@j�M�MC������b]X���W��N2՗b��iԜ_��Bm��4����d�P�yX|�����z���m�@A��x#'$�K}A��xPI�� 0�c�C;eK��(,:�j�g�?��̽��	�M�8���������Ն�%���0m��-�osl	H$��:O�������^����W."@�\�NBk�Ę_u��ʂ2�r�"]���?�x���l�Ŧr����J@�}�us���x����f�ĭv�'�����*w��� �z� ��B#ߣ�/�$��ؔ�l�F;R�	��6��hl��r)G'��9��r�%?E}}�g˅~�˨�ڹ[��j��b��M��u~�}F��ґ��� �>������a�:��;a?�f���>���H�l�g�3���w��(���<��ltֶ����wC��o��
�t��m�G=� �#�s�r�2I�Y�+�EI)��ꅡj��P6Ԣd16�����ԩM3���?��/�%�<͌Ny��N�A���H{:���-��w[�٦a
�<}�����6^D�`�/9�R�+-ռl1��0ksl(�h�,�'0R��1
���}�WQ�3އ#U>�7~�p�����0�P�$���d>�ȕ.!b¥�H L��6�C�EcQ�J��KQYg>ew�UH����i�Y�W��ign+��l�$��D��ƛ��9]�%��2Ĵ���vͷ3�Q{�2P�����TQ~{��9�.��C���%Z�@�y면fA��QLtc㳗Ʉ���f5B�X�m��<>�\��������@b�=
4f)�fI��:铨5Q9�����栈�gsPCp��� ��K�'7�)�A�lE�h� #��m��3!9+�(1!��q�>-�� m������A�� �&��"�VMIf,���.�<�pv?/�d21��/�eيk�	�_�ˇ��H��B�fX�ak��tr�Љ V�@T����b�&�+qk��ЀD���=L��2o��b(mLyE��)w��ny���,�%�6���    q�2G;��%�;"��S��.D��H���ϠN0iF��>�Tb�3A�����i��d�о|�^���b��4���J<O���`^yԯ�F�����V;�BJ�!�ͻ��"B_��O���F�ɋ�j�jƃ�y������D�1�2�?��X�-]�ߞwY�L���[�R��a4Ms�s��d��u��$ݰ�D�}��yT1����5��{�|�n��H��<@I� #@J|�!I\A���M���~�����Dfg����kw.�Y�;�:�磾�0��m�l�{���B	/邬���q}<̛4�?�V�S��� ~�a�u���0O&[m�;�_BB�lZ����5�U>X��?>��u�u��!o�� ��q����z���(V�b��E������n,���G|�:�-��� I^\	p�ֈ����p+�d��"����0.tt|�����E�a�#�̌���t��y��專o�5"9�nmF$�a�	p ��+�����eAװx�|�B:0	����ܾ��G����Q��!�=�ҙo:�q���{�w�Yvdv��^�/(g�l�����C�?>~~h�R"��550i!���=��~����k�,�'�aYp|���`�c��R�.J��Ax�#��M-�<���#PTb�|�,����T4 �P��<�q@ u|�]�"�;�kn��)����]&em.��=���QL�v7O��������ë
��AX��o$���*@�oL���"_���R1^'I�����r��V#~W���+KqG�� U��������E`�Jx<-:��Y�e&��|���n��^l|�!9ڧ�݇�,���f��}�k}�eld���������G��'%	�(C���~Ycw�����G\h?!�2�ZwA�3/��s���lCO�j�7xЉ���5F:��'�!ekT�w�ᴟT�s�T"��F�s�@;P�I�+	 2��]v�\+��Z�G䣙�]"�C�d_a�5%�g9D����d<TF��9����E7�OkDto�1X��.�Q ��ڀd�N/�^�(&⸀s�]#B�'tdu����z �Nމ���,~�B8M�Q�����. �JS$�?�6�K��<�6�ƏlG�,�"�&:��6Nl���� ���0�����S�11��Sƴ5C��cZ�k��C~ `yȎY�39�!���j��b�֌x֯�S�ެe*�:z0��_����˶sܾ>wvsD���c~�/�z.��9,�I1��N	���j�|[ �	�Q�Í	]X!�S�S>��(�~dw���1� z���	�v�V��O֜�gY�O���p}���a����9���n���5V�Y֯���Xmm�����8�r�}BB��%�=��,J���5R�!�;�D���K-G����/a�@��y_��H,��Q�Y�f`�.8��VI���I�d�G��d�i���>c�t����N�J���i��|X�i��Y�ެ���u�ܐ�][#3>����iH!�0��pF<���8�"FO'z���� ��Fƻ�E6���M�H`�M�
��7���D�a��](k�'�̎����ݍ�z:Z��lE�x�a����⼰����G]�]�[���G���J�(���~pD_��yk�F��\O-3��:�(����W34z����Z���4�n�(vG~�%�mN4�Rx�XY�x��:�OD���e@<.了��N+����'
?!�e�5a�(�ɰx�=������&��UF9��k��a�?��f���y[��́vm������C0J�=�O�����8���khFj=�	@t��?�m��6�S� �T)E��P�ud` KW��G�颳=�W�����K��*m�f=��9�r����:2���կ�gG�5��p;1�]LZ�+��0���Իҧ~#�>�1�a�x;*�,�z�'�7��b��xvp{�+2T��������+ɑ�F��A�+���;-+�*
��,��O����G����P=�D��CT��&�����P}�c��c"߼b���[-�^�� �a��Z�H�(".%>�H ]�ǃ ���k��m.0[;�T���RI1]��b<���(#X�ϣ�����f��	ԯ���#����<O����y�l��̖���(�W� ��|-G������'�_��c�ٗl��6�'�Mc��XĆ���_����?�^��I��"�9>�j�������Mz��h�%O�h�y^Lgfk{d\0Q1:"�t)�!��m�K�
9�q!v)�]����Hpt8�f�5Or]v^#�StYC�s���n;�חcg��L�5�X�i�����whG�6��5�:P�֯���i11�nA��.g�"�??z1�tV/�s�$��([ �t���g!�8�-f�*�T=�V��O,���5�� �Kxk,��~�b큌�ز0���\�P�u�|Q�^���i��|�����?�hr ᶨ���W�������I�T"ȱϰ1FhG�6#][��3u�����"։�.K����^?<��״�����o�vDZ���o�d*��ZE�	҃
HqBB�8�����Js(�a7(�6Ǌ��Z�������df��D��x��o��1)�؉���5���:�_���sy�� \��5�_�&��j�M:��ٴj��eF���`ˌ����|F3z�H	�j�N��o�Cj�߉������������b�yYm��,]���Kqܮ�~�_�D���lM���Wߨ����g��g~���^6թ#m�̿�l�x�11fi#\3��(|+ak�k�ه�b�4����pQ����ǌ¾i>�h�H�C�Nofi3��b��M���H7X��
x>��t����L����LS��җA������τѩ�Βc�<5����y��ә�i1��-+�V[��e�q��+�=&p���#+�o̎D�0�����>x�}~�=�1�l�V���:[LD�m6�Ɍ�M�[T!�5&��d�g����Y�7��� [2��u�:CI��d����p<���6 �J�R&��p��S����G�+	 ��\һr<���Y�X�R���f*��z�������
2�@�+��]l�{�ccPߵ�E�e�y>����l<��˙�<���d�w���l��m�UԌ3�/�S�jٮ��Mz�����_���Kg�N7�ub�H�ٖ��4�'�E�NkP���]��OѬ�Ӫy���t"�e��I٧�P{��͊.��V{�'0�ؘe�?`���?�Ӱx�f�yt-���,mf��PFm�%�%�6���C�ȕC�3�Ǘ�� �u�Xm�O�����?0�`�.B�#տ��㼳�%��jZ���}�Gu<+?+ߣ4��kk��<���d����i�_'����0���4��e����8)�QB��R����|Y�ExKV���[��&Y� r��5Y�.S�8)\� �R��ȁw����Y�XMg��������x��_F��7�����������#�eU���"�N����~�ٗ��7=��f�o��h7I���������x���|�?!׺�����s9_9YL�xav���O��Ӫho!��F�ջ"�a	ОA���";�?�k8��B9���'Ce�-�[0`�s[0Ц�&f�#�Jb�AIe46�3�s�2���N��J�m�񂼕���"�&)D1�i^e!6P�� $Fu&��m��E?���I����Ǌ�UV|#m3L��cdC�@
��Eb��O�^�s�O@Nw�����p�BdZT������Et������?�rF��H��H�E秗��u���	I=c�+�|�A�;�j3(:LP9��&cLf������e�e�}2D��uih�K���2��=��[Z}K�MZ�6ˇ���cY�ԁw�-�I�%�QoH��iR�	�.4�;��z����g5{��â�]��󲱰O��|r��i�̮h�/6�9\Fڨ�/[T��fsh��~���dY��e3���P���tS���)ܰ|    ����Y����"L�[B}�\��@3���Ӑj��ßw�l��Kf���6���x���1B]�a�.Iׇ��t�1->>�?�o���i-2Ù_%��}���.kO�{X<�UL�U�Ԛ�M?0��מ
u��w�9?G�G����i�0É5��*'+��gЦ��: �DH���C��p������b�A ��7��f��jGN��=�˨-����7<'�4�s~2�#&.�U}�B����-!�
�%�Am�7RB�P2��<�<�	Tq���T'h�NǤ�PP�?e� ���0�Z�=�R�4�1�?��鼌�,#���|����5ʢl؟�\��PZ]&ksD�W�h(=K�@����z.'�Y̡���k��	��s'���T���e�O������\�iOM�fx<�.�u�ŧ�fD'�� �j8r�^���Z-s��c�=.``V�p�fC�9!B\1�|F\W���o%�w�����d�%h ��� �b��zԆ��{C��ðf5Q�B��:h���Aq�yy3�&C�����Ef�qqJ���8�I�ey��T�A�x6VQ�=@�9O	C:���y� ���N'bV&`r��p����]��P�E����6y������,<��#Q��I��X��Α6����C[yB F\F,}',|_B��w)8)����C�����f���|Q㨱�B|=e�Zt6�d��_�|�XO�<A���{�	�)K�����X��O�U�<֗s�q�Xv��^���s甼,:��RS��M�댥	�w;�x}�T���_�ͣf�*$5�冫����Q�����E؏=�����0�[i���W}mr����*nmp{v{�e�mNx�����ɫ��PB���<_gD� ��ˁB{*��$��������h��-��v�Ҵw��:TF��	j���kn��=!�r��sdH�O���j��rL�6�IO�_��vL2�8�΂��I�;��4��|E�{'���R�e���BtlMd$��3jL�D�j�42jL}ǀ���kx�������.-�v��9�I'�`�,"#�\鼂�. ����LI{��6�+b���x�żF�aMV�q�f#�W�d_��*�l�`r��7��x�_�mpF�����Ut(�G��~��e��>���y:2#��h�i��7$�Q�6��}ԯf�v�\rT
��pb���r��so�޽�"��ަ�P}����#��蜿����il��Bo�y�r L'@YE3訏A�R��x������8�s�]���+�N@f�>�t1jOeZi�T��d� � ����F�9h��9?���'7�kce��va��MR����$��q 5�."&@J��1 ���A�LX�3X`&�Q�$�_��}MC��/A߁�_F��t�a�"������(��ƺo�K��k�2��(��C(d߸�|� g*��G0/��N"�0��u����T���o9�u�ŸW�cNJ���S#L&gp���a�"RAz�L�e�m���oF[�
l+��%��"�sY�J�`�3��P�ڍY&`h�lz9HWgԭ���ae��B���kQ
��3i��t'��?�A��ިݬ&����,�8������8O�_���CJ;�>�=O*."�l��~+�ԩ�D��
¿����èx4R9���a���_��YO% �G���O�������.-s�X�I�+|�ul%�"���+%�DH�q��JA�0-%�2����h�DҨ�� WQ�὏���0��_MI�0̛Vɰd�7��	���q��M`=�{���A.!%�@�-�+lo�#!B>�L�
zw�5��.,3uj���=�K�������<��:��|;?����a�}.r�M��;J�6�T��_��H	���+����|%�Kp{rV������B' B����7'0�u���}�V����;�I۬�n�<!���C#.�X8�8��9 ��	�;5�x�ذ��z[���W������\�K��$YMVfVs1;r~U5Wn��5���5EiZ�������k��� Eg���C��Ԝ�ѹDԽ��`�B8�����ݸɭ���R�m�ep��,Kl&}ߑJ1$���|�U}&$Ʈ�/���
�����*�PW�����K6,�NC#�y~z��Q����09�P������`��J,V�lv�f�p2������3��(%aF
QAE��G�ki�KTc�fxHGf���|]��P����g�E����%�ui���_�"���?ch�_�.��b��M���1<�V�2D%�>�}]����$��� ��g��E�oN�Z��l��ǔ�}-t`L����\�L�w�@ʹ�����R��/q�	���k���Q9��_J�L��HFG�t�;�[p��ߚ~�EW�֜�qHa�	������ɫz��R;-�s�Ct~�A���7�O�bx򬅎��_�f�8�N50a�Yu|WH�3rx��}���r|Wϐ�Cf��u�i$I?�'<�ٰ�t��F�������CQ��C��4>;PG}7�i䳥cA��X�<^��������} &<�	t��L������&�oV~�����	F~��(���X��3"��9���MȴH��%2H���k�|[a���5�ݲ�ק�r�
�^����ex�7���F尒��進E裡�\�<S��m8[���+lm�N�	��Rs���#i�O�����G d�0��[+Qu�VZ&���֖eƃ���?�!{�:
��گ�x:��	U�r�$H���¾K�����u�8�T̳�� ]"�K!P9��W+��;"�U��Tk6��q7�|�v��@�Zե�~�B��i5���F.�X���|x�h��i��`a�f{��e�"|M{���?�'�A�(��fqg�_Z����#��t �!FJ�wf\&+J���D������_ˬ�D.y���|y���/�{�1|bQ���N/Z��j�%�ػztj�?�<�����_*_�o�b�l�MV�m�_�e�7�?w��㬳�g��8{yw�m��K���l2�|�r��nW�Gْ�#���Ka�/�[�h.�'M%�����6]�^6��yO=�Kqy�Xf�:����C��x�37��E���hŭ'����&�P�*2���*�8��:>�2Љ��B�;�,)03%�*JI����y��z�q3R������Di9v6d��$R�2��(:��ڌ��ֈ�Y��ٯr�� ��2)���:�����^�˦���j�$�r^�o��/��^���s�|84r��K.�~QG����!Φy��Y����opR�ɻ+-st�.ֆɱ�g/�-��d`�܀�f�j�OG�a_0"�9�@�Tg���3���r���Ӕh`��@����D����X)Ƨ���MyC�_�n�eX<����*���Ki��t6�?�ևE�i�Y>D �H�ͦIU@=��a���a�G,0�4\���4S���5h�ݥ�KpZH$:���|��d*�$'Ō���a}E���Ԯ��|h`�%��o}%�������x�$��bS���9b�03�D�Q#��n�����rY���a��s�xa�=�Q��Uö�r!L���b���|:���9��6��b}<�S��d���	h���z��p`|����2�ZVgf?����~�-L?�7�Z�y$�P��q怒���閁X]WQ�.;!��g 3�H�T��� q�|����<��K�8ߧʰE����a��Lٵ�S��� I��.�Y�Ώ��H���҉Q%�@�oX0l�k��`M�`���|���l�s�G��Â��=o��NF�~ͷ,�aP#,a@�Kۛ=�!Mֻ�p��g�ZV/Α)<�"d
��)�%F_�a�p�ʭ $����mf�J(�
�yt �>����qu���p�Љ#f��p��4���������c繘�:��\߶@�&�t����j�B,���p>��|�#DGm��ף~�7�D���^=m�?�BYW��F�.7¸��o���3��٩���ja    �
/	���sm�@D\�p�1H����i�K&X�������[Fc#�ܞ(W4xz��,����P-3S���@G`���F�K4�\�̛�/o�b+"���#�%�>e:�0{X�g{�s⻘C�m��tI`�������CnjU#۴dk���D�+��4�z|��w��6.�$�W�͖h7���!?���CӐ���'�t��V�t���z��6$���:�t�n�����\_R�ӏ��2����g����<���6�iW�M��v��y_�"��%]���8���yS�Z��B�fVU�"+�'�5�B��-��N�-)4Kr4[�擫��x��o5S�]��\�� �
C�<�z���q2+{:�:�C0��A~̓���]���k���F�VY>�;�9��ji���rR$�k��p5�\��o�џE���^o���
%0f�v�#/ԥfD����!����[50Zk1����������Xd\wW��`��`& ��1���?r`�6z*��,�Fs�G��`��wU���PcSDP�Y	�2��5K�o����&�M��;R��:��L�I��"ߛ�C&�(��S�|H����0=&�<mp���y9����Rn���i���|��d�����_���3���C��I�W}G�<�p�V���pέ2`�[��p�C�@� �w}�S"���C�f)&��>ş��ڏ�N�[+&�'�������VNY��2���`�_��O谸QR�� �n3A��T^7�RD��'�(�H�A�����L[&��b�˷߁�&���B{4����-��I�>�.�C/�2��k&����\>����P�
�9[-���;p���p�T�H��9F�]((�pE�Dw�$o�@���YKY��T�Y�15&�#$�18lwc�����*[Q9�}ا�is�A`��
*�P���᥯x������>.N'C��ּл\��f��w����������t��x8mf��U����/�c�OyUQ�{�ːʟ}��d]A�/E�ڂ�|�ٌ�Eg|޿;�l��(7K�?>~~��� v1^�E/PW���M��,2�>� &����-�˴�ü�ͬptQ�^³�?up�6/������n���@O�A�7%xW1�y�J9��C��F�He�v 6ȅoM�[���zw\u6�)��M�s���3�,۠�R?�6'�;����~f�/�1/�(#B+Y�zo�0�7U?K������H���
���^�0Kh���4��^R�ذ�q�H9�:-$f�n�ޙO�����M.���_�ɖ��L�d���ܰ%�E��b
��dA�zCFz]a6�!*�u�$^=�y5ؗQ�xL�d�u C!������xN�|�|�����;�����ެ�{���aȶ��^,l��wF��s<��m��݄g2'l�r���p��8�P�:��r�9����^�j����uڣ²G鯎����F;噁��z8w�|�x��C��+'e����t��c���o�nV�>���e�N&�4�5�L�����=����\`A��&�������4��j����]�m{�D����]���<��v��Q�����g���\�9�h�#ڹ���$M��L�dL��Lt��d:�l��p�ק�R�3��(���L��uFf�0�M���{��=�3�JB^�&�g��ܖ/ղ�Bl��}��� ־��?��2�~�B�/_�S�o��M~��CE6��AR��`�:I�$��<)0�G<�0xb��]j ���l��\,6`w�M�7�DA��8]e�s2N��$��bP��_�-�B@ˎcU�?�8ـ���$?XD�G0̒�����ǆD����g��?�H%/�l�4��m��v\Ƕ�Z��q���b�q܄&�C�(I���R�8��%��A�nҿ��2=�i�Ë���=�g�ۮ<�o��9L*��%�
^�m~=o�<�;��q���!��V�$'�
���
-�ӑ�7��G��o�b��WS�_�1SĔ4�~��a�yoO�m���5��<ߎ��y�|\l6{��J^��)�ԯ��c�}$�?/[����������;��1���1�^�]F�ǒ��n�$->���C�K��� ����_��������*��2	���P�P�"�yto��?�Q?�a�0��	� ��.�XBQ��� 6���}p#+�)*)��N$��p� H�{l^9;�-R`]NZ�EF�K�dht���Kh���K�� X���'��vX�ȧ��6;b��-RhS��Q�8�:�H�q�x�B��:4p�)@]��n��AP��wq̢ܬDә��6X�0��O������s'�'��wQzZ��S��{�W������Q��{Ɉ����Z+ŃGX��s������)����PU�r��b�1t��j��P22�LPV3����v�Hl��t�bb�M��d�g�Ԕ��$I�l��@"W"�D�d&&�䇒�G\E�T=~�pЛ� ���i�����GG���z9��@I��;j����IU�`z���} �Bq=|^Eg:-N��y�o;����,�<��M�L�hMד����V����~?��
q�W�7���m��$�\_��}�l@i��o$ ����������D�Qo�a�#��E��aj<n��1��^Z���a�I�	���Vm��<�A�1��'�u��g�S���A}�G ���ޝ�4X9�y�P�'�CAԕ�5r�D�/��8;'CA�S
>�H����α�Z�a�n�i�P�݊�k�ׇ
�*SZ��$Q�/P��8ā�(�I8���`k�R-H�-G�:lM�4D��H���4�J֩���a�M�R<���H���u�|3L[�Bm9
jU[�����%G��ùЖ)�o�_$'�!��U����i#Q�R��RH���F~����1���!|NK���Ë~IF�H���A���9�?��"��[j:R�y��I�-e��0�|�G����u�t��R���	AJ9�:
�	�4�e��}]�(����2ʼ׶�]it~"a�L߈��o�\�[D�o�F�]N�D#ȶ�lDR\�-/
L�a+��u`auW����n����1�J��&,m;���d:O��n���N�)�!qEwEV#��|�mB����ƹ`3 FDW��4�~����+���7�2\:��x�l����	�Q��Dh�{��X��4,'oL�6At-�fw���4M�d��0��lr4M,�f�i�bdGF�4k��[&�^s��1Kӕ��Xݪ���K<a��J�0Dt��!�	��K`�@w]���p��I|y[YP'�4�9��L~2�t�I�����o>?�����/�>�N�p��� �Tӻկ���y�F�]�`7�'0R��1
a�..��QQ*�߇z�~YF�O�&��x_h���K�H�q��$t�g���̇��%��ǥ�H L�1S�`�#-$h�e�?w�Q��՟w��p���ܙ}[q���lt��>�Vp	�h�>^�è�%�_�m�4�b����	!LA�V�p|=uN/�Qg�����w�P����r��z*��h+9{&lt��w#6�'����"^n-F�J�'�]X1��W˷��rX�/�9<��f�/.�v�E�oJ�ü�л|��o k���R�h������a��q3QP&��\rʔ�=�(Q:_h��B߈�k��	�OȌ��:��^ƻ���;��l1���n��`���w��N��V3�W��[I+�`���9[ZJ�4p_�~�/ױ2[oh:(f�63��ifD<b�E�K��q���J��v<_t,��s��x���A�2g�\!<ȩ"��)��R��b���8h��0╕�{�d��y�ބ��'p�w���A��ڟ�Rzq6y����bdFNs��W����f�M�>���"��췤��0 ����f�t:K%���_	u	ז����0�@^!�X/�U����*�V��sϨ�gO�K�91cA�q�g�N�y�S�MZ=���=$���,͵2(��D�� s�G"4�M2�� �A��z��A�*    $,�&Ç��p=�p�vV�ü�^���M� _,Y�=L��y2JY��-NяT=�\�⛺�l���b���2�6 �E�z*��<�g�Eg�0�y2�nv�n�J(���М���Z\E�Z��jC� h��.-C��0�{�4�� m�ZZ���fɭSz5,��͒�ְ��Q�D���Q�Ά�{o�� ��nU��B:�<G}���,-�fz�=�dԃֹ̓X������&�G:���x�=G`�1Ka5˦���:�o�,���u�q����"\�U|6��de��Ī�ǷB��,}�Y��-�������J���˒_O("\Jud#�"7�T�,�}�����7�d]X�S�i�󳡱�X�`��� �c��+zԦ�d��qhh/��6�d=ĥ�oU�FI@M'��-�O��9}c��C\a�]<(w�Nk��z�\#�'�L�WZ1�rEHC��S*��YN��'��˳�O�'hl2D7��5���e#an�����|V)ǒ�"��g���,��[`�u��t�y�ER��-iyR�[ծ�Ԯ����~�l�χ�l�QʽH�t����h$�ܠcB�u^V��ԯ��#�%!��|@�;���Ej�F�ë����ka� z ��Ed��f���_DY򾎋6F�Ȇ��f!��n��&٣��)�@�kB&27ϒb��d�9EX?3dɾ�d�F��=�<���k;�*@�5����\	=O*������GX���&�1,{��hO�3�G��rpO=��Kn�e��7d�42�\��p���������x|@`	kP��p3��3��0F��(ƔW�$RaG0�@(xW��~���e@�:s�W�-����N:I��o��8��|����ٮ�a-��i-�F͸�6�fAphZ�@xs��}B�RKm��רuN`@��qN����2ldO�}]��_�a߿�l4n�/�~rߝ�Y��q���I#��c �(��
H���v=
8��|3(dou�:��rP�o������{�sg�7�qi�Oд_uNp詯Y\�}�/�J���-N�Y��u��!���B{�yׇ�+<?�@Q(!t�i"��ȣWjV�R6��OhO=6g�N:��*�L^O���\^��nvا�dz=J/_����:{���z��lL�~Ϟ��Jn�2J�i	�.a/͉��kz�S�*W���8{8�Ѭx冴5��,ZFٗE\<��x�5�=��7ډҀ�,ɞ��$����<Iǫ��P󁣰���)��w.�CW����e��P��a���v�M�/-��d��W�
Q|��(����wϧ^�,?���f��K�n�D����~��*��q�~�D�=�]%�)_��H� �]I�����+8A���1�DEv�F���䓉��7�v�N����p��}P�������Sԟ���#ϏPM��S�k��E��|W��lF���(�ɏ�����8H4K�w�-z�:#�Έ��@�0��Y�j�EK9_,>�%�z|��8�gɹ���/V2�d�"���@/ui�`Sa�v����U�Mo�\�d����~����'��[hTP&I�s�ϒd�1��d��?c��&z]�')�>���������B'�O6��LY���o�s&/�����6��^?X�}�HG���өw�#�����q�k[O{��=��yllH +)	�%��;�����B8��H43�TUPZ��,@x7���|�__;���3��� �a������tL�p���t������B��g|���1{��*j���u4;"���k��m�gC*�w�t~�&D��-�,~��E�_ޚ%�MY4��0i�pG`���t�Oƙ�.�)	��'���|���d#Qf�eHoH�bΐ�)������	���s�⳻��N=�p#(�"�Ky��yR`�P��1pc�b�;�e�zTq���i)k7�AÊ����Sj�%�����7]��f�o��h7I����ޒ���.�Y�0��gc�P�|u���qz�|.�k"'��/����o������/t1߇��!a�
ٞVu6,B� M?���A5xB%]L���Si��H����P-o5�A���V	�8�t ��(��������p��r��ԝNm��;YVQ2\H�u��o��l���y�霟7��(�y�<�4�?N�#�#/�� �E�D�|>�'����-^�I��� ����,�(��LG�_�2�;��|�9os}�[���-�f�}[MF{�V˫��j^��5�����AʂYu�Ƣ�#oM�:��a��J*�'h��a?6LYx��S��4�Y��G��-����.�X�1�������2��]/�R�蛵���݇Ǘ
)f�`3Y�eV�e��)��&�Eg��N:��I�&��nSl�t�����.V�^�k�`5��~���6K��_�A������x��kzG|CX-������y�7�
�r�p)�̆�X�I/���Î��, �b0�l�LS.E���Ï��t��'�/�r������,�mR��
�b�,�e���ݻD�0§��AԒ��@��=���lb�$�Y2�"�i�ꫮ@��G ,)b�	�晰I��S��ٰ�t*)9��W���F�����P����g�Yx�&Z��mE�65���E�FX�E2BĄg�x�(ÔlϽ�n)�VON|OjM�uE����ɉ�h�Z�i���J\x�Ǚ*AJ�q&3,A��ԧ�Dk��3ݦ/��!ѷ=��3���1Zg)^����~L�׎3U<�뾡���R5��wz?���A������F������S�9,�rr�������������6fh�(}�T�Z�p��ul�~��@(H�)q�`��4�cC@�jӅt�I9#5��y��5�̫�e����_��@�:Q�k��TYF�ű�ef���ӫ�q̔�� 9��0�TbxC�p��r�����rH�6݁07��m��C,��B�A_�D��tB�$��6���7j�_Z���q��A��a/s�>�&�o�r�K�!=�\����_.��@��B���jD�D�l$
Z�9�S�T��Jq�/Eم��_�KH���C�P�����o.���6��fH��}lU#���Ȁ�u9�u�!��j�W:"�w�,����,K�,�`���K��;&�(�B�5vlUc׿Bi��+��C��O�-{�y:�5X�l�Z�ᜧFR�("�^񹧖�hߴ����	�G�D�Q.�+}�$��<�Xp��3m%�bBυ�#�N�eV3�^�d�Js��p�q�9��-�^<��ܮ�h^.����t���i�Թ߰x��XX-���I[E	�H�7[�G�D�W�s�H��u��qL4l���q�_Z����7�^Pju�(0�=�(s������0.S����H[� 6uB�W����2m�y�+̳�9K��_E�&���G !6zs��Ą�ʡO\�W�q�ϡ�*r���+����V�,5Vn�8��E������bJ�q����Yr�=����B���2���l�n���'ۇ�	"6*i�y��@��P@�����Aߑ�N0kmT�~+�����˞z��1���᠃L_�SC���C|��HT�?/�~z÷XK���T��<�!v} i+�
߇B)����32ڮ>��$"���ѝ�����'���=I4������ǧ�ص�f��H�&/��ƃGn,$v��Y����C��$D�� 8�B
+�0F��3ɘ���!t�8��}���o�	�.B�ODE��}��U"����{�*m��a6]ƙ2)���|WV�f��?�_ƾ��������0��6�� o�˿,��Cc�O����L?y�ϱ����e�-���ن�f�w��=�u �(�db	��A^La�&{�&���7d��L�wIҜ��Fp������l���]����q��X�S�i��>8r	%w�ڋ����g-%:)�2ٞ�M6-�sN�Y��kW�h��K���j3զ���ۤ���}+    9�v2�0�}�
F��o+�](!����I�)d\��w�K�F��:�3\�f����\�L}�&7f_��{�￘�/���}H��������[6bo-lm�6k6�*�0�l�.P��?���9"��^�R?�LҨL4� ޑ�.*;ņ��akYr��(4�&�5y-͈����2KΞ��Em�/=��a߽yH+=̥�m"��i3+�p������ȏ�&'�k���bԄ��b��?D140����`��͉���io��a?<3��:(�6������	���^F*��b~L����8.�S2IOǤbO\�1��1��l#�����'�?���z�����I��s����h-7��\�����K&�0[��CjJ��e��Q����X+�L?A���������'��CxNs���Ju�����7/0�n2����g+.�ٷ��ϑ�][q�c����8�g�x6p<S��'<�|I���ho⽈_uN³s�45bf���`I{|�uaD��%��-nvi3mv)Z3��.6�?Kq�c#��2�D�Y�93�j�&�����j�ߩMMϐw����O�3_;�//��5`Ĵ|�~��wu}��<��S�����7��Ș�Sh�������I�t�l$П��xz	φ��	7�kHp�M�@Q�_K�����x�C�Y�@��#�x�C�W@�}a��Ey'-$ߚ]�Ta%�P�֚]&&*K�S'����������H>�����Չߥ!�mͮ6�$���m�.���*�����0��(}<_�I�$ɥ0\��~+��wh-~���26��:&�ԴLc�,��24s\��ihU���M��n��b��M)�ɀI�lub}.sWa�;�aJ<�-}D]���;h���0뗰�_�0���Vޕ��:��r���%�R���^L �O6$�O��g�a����9��s�V�]`Z�7S��[�	�<�WE�y>DV`j�G��-ގ��l�Q��|�[">�.v�,W>X��oX�Pm����j�As��R@�=_2��/\���K�Q�\�^��yl��(��>����Kl�dc;���<W�R~`�äC
�C(#����i�G(�sGPӤ6�&+�K��sIc�@t%jON�?,b-��]��..v�p*��O:��O!C#)�z_"'�h/��d7�:���7�(���P�I����Dn�fb�7f3�s���kA�MӔMv���������N�?b���]��Ex��0��="�X�@ $�0��gv^aR���t����F�{_a: S: �Ny�&/ک��><���i|����]�{t���ґ��8�Y~\�$ϲ��6�+_B��F�P���}O �% ;H�F�������K���J��v�]�s�]�N��?������J���&w���5�y�2�|(�'KGؐX��"��os�h)!N����׎�z
	K�%�Md��.gS��dݤ_����9��}�rh�9��s��
m����q�  Ѓr��$���a�|-/뮤�p{����u8.��9�Pb�C��R��s��	��H�wn�ֲ�oKg�,���@��tI����S�#�;�H�i-��N4*^�(Q��/bFь���wￄ��.��ð�%������en�P�99�EL�]�C��F�l���u��Mˤ>@>����uLtť���0)�8i//���o��	{��Ar�P�"�K�#n��f���r8���Lnt�����):k#�Gyؿi�aO��0󣶵y�.�:��y,m+�uj����
>'0�^˼c-^3�.�)�{2���<�j������9�7)�:[[Q�9=��o+�����̡�z1#%����P0��wg~�F�=j�	*�@��6���.D�3�?7���m�<��t湹M�t�^L���D���w��tL�Β����5�b���XjE��������[u��G�������99�1-g:��v��e�}7��Ǘ���<*�J��w� ��z�&�Mg���޻6��n�ïȗ�����%U�TIz$gEbۍÖ�څ#$d0Ʊ�ן9E�+N �n�*��T��9HS�:����FчN���b��r^����7�ܥֻZ�JY?2P|�h�P�C	���u��NI? ��w�jo��G�w�R���Z�q�q_|���-+f�1ě��H�=D�B�[��*�⋫MHc����ձ�:/E�i�]
)B&�I@��)R���c��w��-�%z�2A
�����������xks�l���U3�MN�*'���6\b8�K7�a~oF����� ����
�>����T�t�n��OFw�o�C{��J��Ymw��~ۋ�K�����v9y<�6���zZ���j9)h9�E�.t���ҲUn�-�Ӽ�g�����
,v������t��炶�$ǲY�I�qI�z~7�So��56�6P��M^����6��}NlW�Ƅ�Mp���i�꣐P��w�>��Y�
�6�a�E:�X�X�a���Z� 螫��C���2�k�f�Ua�/W7����x��d����AG�nRc����ôJ��s:h7���T�2"a��MV:)G������^9�����I��Ձ���k�b�}�N6W3�x�W��@�"Ũz���{������сf�]�VI?��5q �^!</@�ʸHPCy �C�XG�i�ok��{ ����3Õ��=����WP�$U�/.Y���BTx�Y���g�1�"P���gI�|��	�������,�$�+E���Œ�1-Պ��)���y^S@�y�'?�?�.�ǟb*�|�m�f"E\FVQ#�g"�}gTq�;���FZ���������x�S�����r���otGd;]yEX�����gR�)_�z8.�jz?"���\j�Z2Ui�6��@��	݆נ���S�O���4y,�qM�TM�\�,�w�&�JeJ��.�PcZ���]���3��5�4�)�C��aw�o�T`������=��exV-�(�>|����e��	z?�ܖ�}�=H;���;��|��_3�k��(���fSX��s������P� ��DbZ�<G����d����q߳(�Vs��挣�S墘���G�G>3nJ�C[��\�>���z��1-�䜍��Hr{��\�#M|ɭ
&RF� d�
�q#�%Jk
%�Q	񩣅:�!c;7���I���B=L��ʗ��l�r/���bn��m9ewOfz�e>��v��|�Μ�)������5�(l��-�P^ܞk��Ӊ�i1�m�f�Wd��`U������&�.qs�'�c�7i.��lGh�lC��E�rI�`��D�I�|���Ez�P�����B��(v`[��=N��/��/����aZ�=���`�Vt�[�ER��/�|tgƋ���=/ǫ��2���b�n�8c�CKQ�K�]g6�����	o���n�����:��d�Hj�%(c7)�{�"��������"3��Q�|X�� ��&ÈB��PC���]��!1�gjGT��P�>05㇒R��"!�Q(`��O!w��S��"�����;-��s_F̎b38��.iĺ�i��������F�g��U��\Q{'�f>)�*n�('�a3;/���~u� �=�Sq��N?Pvn�[7B|gڋ7	Ʇ���zϽ!ǀ��ݬ���sR]O����'J�ƀ�� &`mn���牨I��s���(��Y"��}*�f$������fE��Ӵ(�?�'��r�?M��'�2�oݭ�&�'���J�ƼW	BT�J�?!��y�̝T>�<1�NSzNړM��R��)�UV]1�#U����%�\B��	z�x��|[�'o�yZ/�Lc[�N;�8_y�q��索\D�h	f ^H�,�L)�	�D�Ɲ�+���Dq�Zۉ�l+e�	t�l��21��~4E����`�2CZɞ���L[,<��Re����#;Q�r20S>��d���Q4%�}�O�Y@�7�?G�4#l!�~    �E�d@U`Y�N�����(��B2�Q ᔓ(����+�?o��`����=vŲ*��M�J�d�zүW�d�钦�+��o�����_f�J1\L�y(���\r�F�{M��b�tlK5,�#��>�8b���ޫ��������ݳ��PuGMVJ#�m�|�Ck��ZpŴg�VK
VJ�AV�4������ܲ���-+F��}�̪�{���G>x�w��K#+ۣ�����I{1�/�X�V�`�l�����~g���n���;��jß�-�Ý��U����#eO�ɝ|�c��yn���5��a)�-m�r۬Xݞ��+7Yu�N!oO�U�RKX4˧�E�J��,Aj�M��z��jV�5˯7��(5�f���1�H4��}�]@��hC�p� ��!�WZ[�c>���q��|H��ؒ\|.�؞a��ts=�Wg���l�p�(��%O{��м)�l#�/
2�����C��!�Y@ֿ�jD
�F�A�ߟB����+��v�;�ز��ͷ��[Bۦ|�P�U �2+e �4Z3�(������C�E�v�; ���®�:,G�.ǋ��w��'��A���	��F���}X�0x�x;t[��8�j�2�?/|~~��7\��x�����z�6N��/�2����5�B,d���L�B��,ϵ5ի,������6������!��pƂ��m��%?��F���v3}sW��"x�nح���������q�cǏ� xZ��UqO�b����,&�	��|�
���a��#}���]����^�&�-�ȬԷ�t2,s1���bx�#����>�!����џ[��?��AoQ���0bjn)�����v��4�z��v3�?�Q�^W�� Ï��ߛ����F$���yZO�^��lP<������(�r<�}�;^��!q��z\M�G�������i��i�!����>�����S��l{��0
x����8��/p}���OZ.�y9������˝�F��b�*��L��_�q�52w�3�,��������G_�/e>ƃ[5���N�K�z�;�;��2�����"�$mSv9��ń�A��\dg��S?��j��i\�$�E��y�m�Ʊm�&0J@��F}zm=N����D*�l��ʷZ�"��C���<d��7L��/pg��9�Vw�����͹�k�e}/����YA6���O�9$O�|�=��G��ѡ�68]+~v�ub�W_&��s����x�w��j�8��Ge|�1.�����׼*�w:�o�=.�I{��Y�����4�ī����.�T�fe�]���s�&$��J���jcoo���mnF�,{4���YOj_q2'�,������IM^ȏ�}�#t�?�&�8���~���+ER�k�s��:ݚ�$~�ԛ�-B�+e��F��瓌c�j�u�a�V9ȥ)廦�h�����$�>��<ᇒ��2�:�4�� ��ÄjҜ3Ӛ�-R6��a�n?~��m�s�np/�i/����G�'�lr�wM�M�T)�kr��$Ji/P�G����oQ������a�r���[�r��L���wg(�C�0������|�v^��Wv|T�f7�y�9_5<̋͡�}M���#p���/u|�s8y<�_�gϣ^�ٜ�=ޖT*-n'wf1������j��z�(�Z�v���ӎ$s����j�)s��H��#2j4	��b�������e��M���4�tx[�	5�>��&�.դ|7Y�=�X�ʫww!1���w������+�?����R����VDy�.Y�Pc��I�����O��UM�w���[Iܿq���8X}m�?��j�y�����'�W:��6p+׬#{��j��`���37Y�Fd������M?��Y}�7CQ�熛�:�|�x��׸�֦���*�.ld��2M$ѵf��6��qK�2J�c9l-� �8aAϩܿ���Z,*�(>����u-B�Oq5r��UZ����7�BQ�>Yf�eV��I���!���x�2���&ҒH(�-��h&�Q��E�iF���H�rI���J!����sVˢ^�t�] ���2�"��@%�-u�600ÅP�n���`������`DgZ2>�s���ޛ��~�xD����C�`��qt��64a`����L(�{�/C�Z�g���w8;��JϨB��{��9�{�p�@���ޮ�g��(?���]���i~/�ǥ�����9�����w����p�)_�Y�@}�'��*c;#Ƕ*+�����~������L�A>z��1��=������kl�7h�c���j��
���{���b�;\��Ql����?�xÚ�ۯ(���D-��{'���z=(Z�A�OӖ��������c��b4�*lFn%�����6,���`���B%���?��m���|2;n��AF1�V�I{×�]��jnh\V率���J�:�gUr���Z"r�ۅ���"�e��x�������x�INKM!Ȍl�Ȣ�NrbȠ�(���Q��GS:Z��=d�����8�P�LR­/ 4Ϻ���!��Cl�=m�>�.���9�����b~�8_c�d�?���XX�V�5*䣂�Dۢv{��'|5�\��"��4*��ϖ�'H�&�ۻdi�D瑴ުk�vdq�{��^��dE����7Y����D�I�B���T�I�(��h�h���©yA�)"T��ڠ%��_�ȭ��U{���"sY���
"C���	�Ֆ)C��Q��?�Y?�i?�7h[��-3o�紹9�k&XW��P(��.�I�B|� ���p���%�\�$���O#��f�Q]%,˓�r��r�b��3������%��T&��L�d����,�i�7i⵩�d����k��Cƹ�Z�T�*fp�JZE;��o.>&�t���O���-8�U;��v���-B�w��H/B���S��@�=��ﬀ���Y�
���K֛U����N�ǃ��K�����mm[��Sµ2�hu���fb��XgE$BD�
��ǜ&Fto��^��:�nj{A�s��uZ a�u�$.�vg3(�V�}�/y\]҄�'4lcPj�r"y2t:4i�ǘ�D� ���@,��	�v�<�k�Ax�P��{����=ÛE"~�ez�	=7�"���e\�/i������i~6��	��9�W2�M6iq��fo���=�1��iy`�s��pf!{�\*�^����q��j;P�Aܷ�h�&��m$�v��L\�Ы��j;�R�sJ7�*�߼�.��n��N'��F��f�6q�(l/4��M�}�k�����]�9E��IƔ	iG��x��c��y�R�Ҵl���Jv�ӃT�/�d��Կd�,WYN�"�t����	o�4����x�&}�H8�"�D`����c����2e���	����d��nM��L�=�k����-��x|�0���^n�=���D?𲬖��`��|5��hz��л'���}��!TC��<~UC����-�0x�;[}���m_�eO�K6_顜�ww��p�(���ax���7���%]B\����=8�C��-[����3'�.�}k���:>=�߱�|E����;��n�޲|�vA�t��aZ_7X�"�9oQ�"W~E2wn=\��z�)d!E��ޅ�{��.nD��OM�����&�m�(��i������i�T���ڋ�o<�<͹����쾧������Z�s-�k~��2aQ�T����h�����%��9��61�Lw��\ܜP؍�qtDv�f�[
�$��);����56�\8c!#	�GlHgXG7�L�o����TԦIik�E0I0����_��a�!��%O��s��s0��İ);����R0�M���(�N�rd��\�q�\Gy.E��D;"#�dG4�,�Ij�M{R��g��Ư����y�9"����붴S�����eRL����4�s�2��xX�����;u	U����0�B�G�a�I����s�:(������bV�F*t�~N���d���J��7p7e��,n65@��k�EXgR|�Ž�u��
��'���qv��	�p���    �cX� 	��B0��n�(�B'��L��\q>{3M�\8g�5����V2:)�.�"���gIN�I��
�u��S8o�4���r�ۢ̿���Tb�Z��N�!i\�e���8|!�υ������Mء�AEL���;�rt�9Ϋā%�[=������qr���A�6y�Ӌ/���|2���xb�r(��r��w���k�D"��>[�����.t����V��Jvq˧����'n(��*3W��t�{�s��&��͟�É��|Q�є�� -��)C��!�b�b8���#����y�S��,�`2�f�<���g��޲�<q_j A����HIQ���TLX���<���쏮{C5���DɡӺ��s�~�����ҽ?����Ư"�{1M�L(����؈�Y�0=�����ʕ,�G%�\��D���M�cdޏWs<��� �TE<ċ��ֆ��xdi�~�A9�̉vX��i>��|�vI�M�T�����81G����I�4���˝c�� ��X��V��`���W
������27�zy�n�UZ���4�R�u��2�77�Dt��\����e�9�̶`���ȹ��Y{��n?�f1�ٗ��]�|e�&C�"�Ӟn/�u]J��,�Y����ޢ3C|gӴ���Ƃ L��iO�Y2T��.$�X.党3��c� ��(Lȹ:�=Z��C�ϴ�@[L6I=!�5�<O�{�h�@�����6�H �M	`��ʡP�E�hJ ����m�/<_q���\C+C��ЎÑHr~`���D��eHrJd��v-j�*c��(ۚ2p�
����z�*�H9B����d�3�*����	a]��R�X1dH.)�h*~���8�������.��s3�Ke���6aF�sJ;1�,9���M^q4Ǧe�7���a���	)%�Z�@�c&�TR'	5ZD�ø�5��s6�A�s�<!��"�|���j��z�>+��m��r��&�B�����"<��â�0l�a�@����P�E�?��o`��0R2�>�%%����w�f�&R�状�H���̕2� :a�N0ɯ����Wq����n��m'Tyc"58l�����c-׊�@����� "�<�V��*�/x`e�{,<�~]��w�~�Z3לs�ڐ*-���J�r�n>V1*��Q37d1�jM��s��%��7�M�Z	�\��.4y,���\��◔�'s>����s&�sԬ��Q^�@M�)& �I>7�G�n9�Q5��8�f?��$
<k��F�C�� ���u�:a�P�*�1O3M,��ch#�;5H���5bQљ�7H.n�I1*�"]�,+q'sC�:/_b��~��ސ��/�^���Mz�M�o�'��H,��	*���Czi����$a�P?�$�>����AJ�5����L߿���<�^`G�[A�SAYu�A�)Dv%�|��/I�����q���A�ဩG�u����"����.�
5�S.� ���|d�0V�Q�.<�baf� ���� �kNy��V75G|�$��@񐅡���l�w��چQ�ʽ���}��ݥ9ž?r{�~a[�\��<L˳�r��#���o������|t��C���n���/p�'*عQ�m���{�m�z�>ѩYpn��PfQ�!]��D�^5_�υLIR>.*5\
1�����)����S�n�E�m#�)���Ne)��?<t��&��&�.&/u�T\��EF�MJ7+2��3���`�&s�˿>w��IYJC@
})�B������Ē���L�;W-�Y�7D�Y{���&������$���𶖢f�y4C"�*���%9Yc�Dg3I�H{"(JXÌ�0	��(x%�R�y�
z��
��n�1kM�=T$gL��K�Z$���i��eI��pNؙK�qo��r�o��&-s�l�mn�y��B�T7hǚ(`Nm i7��QaU`�L~G�òƄ�v���6��C���C����'%��r\�ό7�Qn�喸!�c��,9O��4��Z�wm|1|�49��!d���6&#�W"J3AM�K8��]�,x���Ҟ�^��;׬5����1���?{����Ǩ��n����z
)���nxsƉn��Zjs�M:����)�$��(t������V2z�7$��#�@3~���RV�?��X��s!��<M����l>x{��;����>�F���"aB�6�eſT���`Y�	�b�+��^g�$��vH�B����苛��e܇+��YVי~�Էi���d��n8N����B�8r7#w�f^�"�"�PJ4� 3x�-�Mh�q��	�
R|�Q�0����Y�p-j�,���9����ho�DRū��2�a�3���؁]���w��������Ľt�U���Y�?�ʻ֛.�NA�z����42�d���ϙR.R��w(�RL�����7n
{�HR�ԑ�,Π��=q�u1���yAi��<����b�y�;FX�k��T�	��'�*T���[�ꋢy�,��v�e��Jh����Q����!u�̥�2�w4Nv��?��fI��l�SV�&��KfIq��	�6VS:lʺ�
��M쮋�݀߹y[�qm��B�1��z�t4U�<,�|<zP8N`c:3�y�ED(��f��B���
��?����3&�VE��`���B��$�A��De��A�F��@����:�����yk]��"�qu��]�>��3J$��(@�I��6��g��4�8Q<4#φMȳ6�[T��"\�LԺ_�
�4\W���
ǈ��3�`d8=�F�	���@��eZ��P�E�f|5zT��lpw?�t99.2��j|{������=|���N��n���m�ԟ����i�i��
�=����Ҝ���F���ʪn�fx=Nz��n��G/�b���aq�4sk� �7N6h�{��
'4m��&~h1��`"����z�Qa�:��w�w�i���I�����XJv)�2�.�j4|W^��r�^�Ί�9�߼t���ʝߜe��,k�,�ӻ�I>}Z�O��z2��O�x�L��dnE�B_� �d 	��l$���Si}�X�Gi�������#�}�ش�٠����<>�r{��7_�F�;x��_�&ʟ��~�4�O���>�{�Kj�������@.rx�ӎݪd������$/R���C�:��҆��P����x��_���c��M ?9	�5?j��Q[.�p'���#<E�֓��rj��p�B�/ʌ�+M��3'yH�tj���lS� .u�\�n�v�j�-γ���?>Oպ8�r�0<��oo.�q��6�/_�A����z��$M�����w�e��#�#�-��4iR�U �CTz�ſ_��X��u�C��9�]�v��j��6�#��j�X�{�Jj���WND��Q�b�h�Ѧ��^X�!�-aIkܢ��h�u�j�78�7�Iq7���E2��P-��.��@��� `�Q�)p��D��0��b���>�"�M��5��n�ʖ���sa�[/fy�K)��ßM3�ͦ�z�"���uZYrqS��L��4/�*ccڬ�����5(=E��
ܫ�5��� y�]�}%��:�iO\�j����é5i��f�K�*�k��������]W�#�noV&��<�~[�%o�27EsϦU�F�"Zפ�N(��B�Nb���@�0���]����Lu���`φ��|fV�4�,� �W�����O����&��u�I�n
�~t�'i��k�/�'�<�~�.n�C�)B.$5^ ~��!�Xed�{ۇU����Ҷp��s�[K.��gH.�<.nV(d]�Y���A���t�N0��_W1�>��Fk\4��V��X�(�M��H��kt�[MDh���0�OMx�Q5gA3趟8}x��c����܏��[��]��i9~�����?��~����*x�`5�߿���P~�v`� ��ФӴ�$P�m�dF`�3�6Ⱦ���&f�4�x^��z�wfpg%<�w��G�l������V��Rc�;���x^qr�o~{��%�j���Yq�%��
���ٚ�v��<�¸k���    ��ɳn2σ���d���+o����_�������YF��	��D�����Qh�	\-��	�B�%=��RA�i��Ri���!�]g�8� ٹ��	�t�n�)����M�H6��SoBb�}�Rt{�ۏ��o�j���l\g�}�|[��<z? P��ߙë+Ze#+U�"_iU���D����0As���v��0������?�����K~?9���R�Ƿw�y�eD��\�o�}|T_��#E�c���Lu���{�!͸|����k�T�IS`�UT&T��G���qK7CȐ�8�G0�_�t3�����u�<Z6��Q'��N8�
�4
����BH�>sM���^F�l�[6�����Pwj4ŀ���[q�.��WI�_9����쎱��,��zNm{�x��K�)�k.�"�J�UWψI{�@UYo�gE�'�٩��؃����k�3)�9Ks�I7T9�}��tV�g
	�j�G9%Z[�1���P��튓���
�۳C�p�R�K���$2w���k�*�~���J�����q�?Ƨ�M�Xã(b�D�Ai���Q$t�tY��6����4��%b��#L�Ow�j2}��_��vv������*��
d�
�O�^9\��n�e���C��Z# 9�\='nt�|5z&��~_�v���|���h_*	�SB'|C���)���Iv�j
�}a��/��=����c���N���&+p\�]ܐO����1�(2���i���<m��Ԭ�&��<k¦�_��8��V�~gqLPv,�֑�u�	��;��ɥ��8Wz�x�ǔ�\m���bu�x���R��9���Ad8�=v���T`�z(f��b�?�GbE���Uɤ�ȬvjFl��E�Dq�&�2]������UV|���^�#��݋ϳ���n��B�u�i��~Q@����)��EQ����H��*���<���z��GB� �VHbg;�7���]��	�9����!�^��b`�����C��1�J�+��g�noV%��d�M6�݉�'��|r7ɇ;bi5�<�U�E�p!�43���w�Y*�r|)�fP���a�Ms�٣��(�\
|nk��ଢYR]B��П�P~�G��	�K�I�:駧u�Ɔm�<�n3��"�;��q�KMhh|fB�b���Y懡
�?��g� ��O��z&�5�� �ү"y]����Xa^�
�R$F9���uܿ"���:�nN�y�2����"̋r�)�=��6Qi&��&Q�B��k�)�ZB`������\p���y����T(��T{�S,|Ϊ����r��9��U�L�H�P�V�UVA&Z|��:9�f�Ӝ5;�61�Di(#YЄҾ/LE	$��oBI"ͥ'hy�w��G����vO��|����=�՜�{x5}�v0�PZ�����ʦ����}��mD�|,�s6�_�d��Iq=Mz��ss������po.�U�{�Z
?$Q��	%���z5�j��>7A�[<����hs����9�_���ԚW�Mh�Õ��U�޳���u�ߔ�c��2��<�8a}����WwX�?".���VwtH���G>?d��d
�9����t���Ƹ�>qnH{�e�H��uM����1���5R��BQ�A�O_R��J��'�l,��>i�Jr�ׁ3�D�%�:�Χ!�ڳ�%�ς�<l�_3�}�+a?H{�[+�V�&}��*v�����p�^�y%3��p�K��ڝ�����f�|P
or��#>�����*�O!��xB����Wķ���i֫������V�:ǔ��NV��Z� fp�hV�ugE��f�c���D�h�g?�f�0p�<�xШv'�q!Q&��7� �
���(B~G��̚� ��������ߞ�^o�53�ܐ��Є������z}�?��*��2�B��4�R�uoLm����0݆�rR<M����	4�H�PٚJ2��"�\��b�n���
�S�^~�s�[_io��K{�4�7�_�Y�r�V�	�,�D5G,��
鑈9A�0�VjH�=,&O�r���W�w�ۛ�ʌQ�~)�U�/2���q1�fE*��E���D��إ��n;4�|~?�աi��,��ʈ���"@% _����'��iü�Ga�eU(���B^�>��s��W���
i{��e�\���upJq6a�R�36¡�d�ǷU�@?��B(T��/
6��_V�.��ʹP9c
�5#[j�9f�8�3>�ؙ���</͈���~ڰ@��Sbq�EFD��eh�0F�P�(+��n���wTſ�Oy�Mk[]�B�ywY'w5��f4���Wb�{�l�"���9.٩�^�t�D+,4��ib��.C��B�Q���qk4�C)��R5������RR�L!;f2��ϯ�|��<��a���ӛK�1Dn���
U�<n�J�t�DP��ɭ�u:�"��\��%�@^Y�
�*C;K.bT	}��>B���$,>9�����>f��vs0��)�>����A �I�H�S�!՜�(����Bn�i���A����V���i��KB]�l��V� ��l�Zb2�|���q������^M�񖟾f_=���p����w;�EƢC(:T-[�[���"?|1�[�|���4;���ˋ��Y4K�7��L�ى�����]�Q�W��fYQG}� �;\tP�6�J
���vN��
ϩ���s����y{5�߹y��l�O5����HѰy��GYȉ
� ��΅��=J����#�q4;�� ?��};� pzN���m�:���_͌XV��N��1�׳)Y�d���WZ����N��{D�֐$��j�S��.��^
��+��&A�W���UR�<'��K��:{�����b����q�+�Q�ARO�6�T �D�!��9��ʧf���3�����,�u�"5��=r�]�����?[<<L��e��{O�\XN�cVU>�Ov6U�����.I�[�h��^�����|�-�͎'q���Mmjqυ�G���K
�b��U�$̸�R}�.����*���f��|]��'���"O'����R������͸��0b^�s;Wd�UnK3�f���4��j�/������!(i �lUw�l�ȬF��ҹY���<��>^J���7��Y����"��"�]�c矐��7��x����qO:�49�#�y���<n#_��p��A%#4�h��7�鱝��8	��F�T����~RL��t�\.�V������]>a��d�K;��V�I�gE���!7^�1t���>Z�M��yb��G��V�ag�^]��#��g�����v���RԚVh[~t�������jV� ��X�B �9���R���<K0��C�Z�����=�+O�n�X��ԧ�Am#�7���������M,6о_f#��@H��P�|�����uK-���ZH�s��r������״������s��7��>WP
���n�"�t{7'
�F��j�K�&E��Q�L�M�B�~�#���I:C�Ӛ:��|3P�7���]�,���B���4��������	.��I_7�So�$��G��	_�y�bΌ]���T���_f�6���2��$���@���'���b� ˲�{���@�9��[�}�/���Y��b�X�/�������ˋT$1�*$��]6��ߚ��m�̩F��FI��������Ք�ІڳNC~�Hd���^�+�v)E{��~L����Z��z�͔����j�r�Y/|�/�J_�(��˳����5M�S�SM�%Մ(�4�� �����	Drx��![�;@])�9W��=�P�,~F�d�Mk�⦎�(Ӓ�C�V�,v%�Aɉ
��.���e���3F��M�ҋ48L��@2�L�!q�h�3I���_6c��.���_
vN�k*v��sR\�H���%U6�1P���sr��&�_����1����e���B�����/#�d�Ǩ��0VEĘ���aMB�������Դ�^�7�ִ2Q�yi�����z\�_M��~�=�<��t�F�8��dl    ��|Y������|�ɒ�B��o����5���厎7=#��l��c;xPM������QN'���F��x���s���G�p6��w��l8���V��{���	�cz��r�y_�U�û6[=�=�>��ωi�U�I��1���c�ܮ�Ǹ<�ɐ�os=K���7��E*�ң�&C�f{;���f2# FE"�M<>��^`��\t�0^�Gև�s�C)��|��V�h�S�U��}���rk��,�d���Tz��F3D)w]����E	!�jx�p��F������k$�<��%��H؀K?"\�VX?�-ء_+X���б��,�3{Nlk�{�Uq��Z�}�p16�y�Ψ�Q$E܋���X%����l\���l�h3�&�6��t�a�)ќ^d�0BZ'|��V(KD�b��ܫX��-Y�[��%�+^���xH���J�uI�w����,vQ�>I�d�͑{���l�*#tR��&�H(2I7�4!jC�VS�#����en��;T2��[}�[��̶V�e�o���X�M!v_�sJ���U��I��M|qB�6�LN��S��ڗ���Ȩ�5�o*|�и�&����|%"?���}x���g�A�AAڣv���(}�J�Y�s�K���u���$=d.����<O{W�I/;������d��)|[E��}k%EB|�YJ~@\�����0��WܗY
���h/|ǽ�ۿzI���l+2�K�I����9���'ѩ�i4M�l����[Z�+FE�iRE5�A�$���Cp�e�7�Ϛ�ۦW-o��r�Ղ��0�i�\�v�;���I�������d�p��[?MWO�Ѳ(4�����}�����B�|�8n>oɌ�<��t����aiu%P�8݄��Ҋt��,�a�6󄺎����ԓ�
�q1b�S��b�M6�����tj,2r䥚Q13n&s>�L�qx�@���C����9&<"�&���{��z����#�薾"B�@�
@ꦶ�=�:���ٹf-.�_1\�7(v��u׿�U#�juI�͕H�7"���qZ'O��������2j2LyZ�|�C��-�bڃ�R�%��Zëy�s������G����w�ohzN�n����)���L6��l���֊��k�\g�
�]|̻���>����E�-�������F,����;��,�����2��>�
��<$�g:�������JG�Г����� 鹤��@_�*L������-�r�e2�2y���?�X+�/W���i�մ�{���L��s�"������iڋW�o����p�%ƹw�ۤ�޽�:`S���-�����*Z)�4�h�ȋ�H�($ZVi?'����-���H��ڌ�U��tߏ�φ���g��r�b�x?���]ڌǴY!ǝ�'3#���n��R����`�CZ��=]���G*�ZG*�U�'봏���<�!ZQ�{��f7�s�UW$�MH�7<���~~D��f۞Z�K����;�J(H��P(Ϊ��A��qG7Ю"1�>��`�T�S�Z�>��3Tt����6!z��+ט�!�5.�*��b�,��>��M���Z���8TP{��4`�P���$���RI!W&�*b\d��~=F�l��s��I��ʴwɒ��Uܻ�V��J��{��*�y��^V������͛�C�푯݉oJ��P����V�S����Y*��!T�!��	(�������Y	s�k ���f��ts]eH�������.7�0erq���#�K�����AC�	�m'�|����P�e�MhH��F�F��,���H��� >�.<Ozlֆ�AG�m�����I�9禵�3s7�ۿ�Z�r���&���cOT�c��I?�Y?�A�y�,6zPq�سM~�G�0ꚒL@��
I���3nl�]Ra��C���c�=�����%%��@�X����,�F�ٰX��"ԩ�٧�����r��+&��љ�T�n0)d1VU�=�����������C8ZR�����[}�B ��a�fV"����窮77�uZQ+q1I��,�g�dS��z�-��?��y����+�-�6��߮D�f�Fyiu.h�t)���e�r��X�p\\Y�'!��yA��7�`3o����	d���F&�6l��a���p	h����"��%���*�%�:�4,����8��\#�e�q/ĥnZo���Ɗ!���8���Q�y�b�Țv���L�4Zf��BF�,�,��aˤ�RiB$$�Z���JQ�Y !��Q]ڲ�������_2��� ��̛�sBM+�Q���&�p�1�[�"�A9��_1�f��2�nNF�8~��^�ڶ�h.D@���#�~H��$���6��	L��IxG�f���)������h`s"�nX��q�����*���t�b�V!K��dՕ8�c�������� "�Qi�B�V�\���ud�#߅�ԟV��M����e�u�	;���5k,&���[Y�^���n�ԏΠ8��,Oz�$�y$�Bzs��7��VY������t��'5��'"�Iĝw���jv5)��sq�1���Ue��IZeӴ������e�g�l1|/�_�d����&��P��q�'�o9�7��n�j����sE�����)-h:���M�O��:�7����!�����5$۶���9ㆢ`Srq�j�,��IM���*P�o�M���3ޞ}b7�qE��6`�P�1d�jh�>�>����H��9�^�n݁s�3��;-S��3sNe{e:X6����u��)X��d����-X��c�{
_�,�)��7�m;��L�8�J���9c6�"�EG�_�#i|%H {@X��C\C�Vc;Xj:��?WV�~0����������K	/���n,��ȇ���Xf���Dy$��ٽ������eJQۚo}������0<P�=g�c��r�_j����)���ԃ�*��U�i)���K���O8*#�u�4
<x\��_�ޭ	3�SړL+ҡv��ی��(��M��T�Sq<�~Qݝ}Y-Vg�`���5��������z��\vd�Gq�b�A(�Vu��8��� ���Snk�v��}�~|�l�~H�w�6_Q}g�����[>Ew�|�gUm"|�NE>�U؈K�2��ٸ(7n�"̧�J�ǽ�!�]|q�J
d���ƽ�'��	���Q�M��������<,툍����|C���ŐH��
)'��cNuT��챝���L�ܜK��3��uq���d�.R�XI��i�z��d��+��d������Z�4�8.Ī�A�'�f2�� -���0�PÍ��P5�>a�l����<׬�~o\|�����ZeŬ���_�.	�N�.|���sRex�S���k�����O��6䣡R�LrB9v�tH�s�[�1OtGo�����q~�*j�\}�z���n��_f��f����&+�$5��Fֆ�p���K�Oe��8��6��-B�����ۦZv��0��A0�I$*�pZ���B?�p΀Z����Zu�wO-�KH^Dۛ��C�F�n��D�x�۱��i�.���f6�^����	���A�}�6-S`wMz<�&f�P7P�G<��Q�E`�xXѾcH�^��������%�=�hW7/�W��lV���iگ�����X֋7ى4��.�o}��FJkO�.��D��������>X��C��;"��������b�~6�/��)e��p��j�Z)^�md�n��BD��[<Ln������L��w?���T�O�{p{Ⱦ�8
��zPN��:|O��KڻZ��I[Su׽�M�� <��]VL�IuZ7j�Us<h�1�z��pp8FR�VI'�G|T������/ăF�Ń,��,mmB�)I{A
���Y��WȒ9d*E,�~4�X���4�n�ݿ>x���p�)���Y3UT"�8�GΣ���Y���A�꽛>���{�`t�h��K{�9�n��C�sm��F|�#��[%�l���xR�=�;��    )Uzt7�gc·g�0�[��EGw���os����Ֆ��m�X����A�q���\rD�
�>��b!uʐ����d�Y͎���������/���C��8BD��uOO_�|2��j6�����4+�jp� �E��؎��> ���s��Z�y��"�@��p�QԤ{Hr����C�fi��/q�����\�����?kөo�{��-��Y_��:�mfN�q$���\$�p�����Q!�A�����Ūߩ��9��[�!�n#H�������fu���u���l��ӏ��"�%�C�	�{xY?~Aaฦ׍Y��\w�G�^|�5���M%�%m���`a�=��m>	��=����S�1�ю�q\���>����oO�u��"�S,9����&נ�.ʫ�R�l>�����}z����ՖY7���pR��B�gq�ij#������~(�:@����|�Y�z��{���q��=�(D[�Ŭ�\��s�պ>�M��E���ި�qb\��^H�����{Gg�-mؽ�0���a�I���p�f��:J^�'j_|cS�4����g��P������z��S?�l��+i���'�����;�$:������F��&i��ң��{�SRIX�4��<"������	��QG�>[Қ���{����o����i�������m�����|�=�#�������V���}#��S0}#a��������̗e~�^��R��_���p��!$��4�x^�o��;3����|daG�l������V��Rc�'�zѵ�M.���?������r�kV�y�/����n�&��?=�0�F%�o����~|=�> ���{|<��3<�����s��L9�
sXQd7�5�)��n�q����l2���&t8���Ò*>��d�p �O�ý&��ƮW����䝳���'|��B�hXv+���P�@gx���e��J*o.n�BŖG�XJ���SVb��){�"?��-�h�,�nxV���$ӺC�q�	M�����.��/Fʋf��0�{o��6�e��N=�_@�3��n\ Е� [*Jl ���� ������wo�vy ����b���	�q6���Z��0�d����W��06�� �2΄* ^p���;G�C.�Oo�.P�r��:'��b���.)�	"#,"�j��T#�^�(���˸Da��C���.��`��s�D�
ȫ#ށ���o�Hh	e$w�V��P++�(�� �;��An�٤��@�����rw����G[+dYAPs:���[r��x�[<��2���0=D��E§5�o��6yz�Z-}`��ӂQv�v�n��b�Z�zsV����������:�[�d��Y�uR��t��l�+��A�W�`G���[*�DCɤ���<_Z:I�{^�k��i��q�)v�.�P��q�CT@M_R��R<�%�P�/&w5�(��饌�W���]���b�(��������j���R��v�@�-���b[r�7-0u��n���K������,o���S�5���O��X/���4R��O��D'[K��/�C�n��<|V�hٰ�NN8ٟN�m�t��Ogǫ���A����Ƹ����l���g�lJ	�WGT?u�wl�}5@�zQ?L�~	�Q$H����F��EpE��d�[,���[R^�q}y�u���o3�m��>�%,����>�VY�P*��=�#��D�����H�ݞ�n�����n�T��7������]Ė_�?a؋ڦ���n��&�������sR��	�����c�i��\��:)P�39=H��P�l8�'��<��t��r;ݻ���M�䤚�C���މ	�
�'u`��C�PM8|I%;����H�v�-�k(~+ �=Ѻ7���<C���%��v:��?U�C������`�U)K�P�Q^��Ɇ
i^E^>�EU�O�:M5��Ӣ�BA9��mՉp��{���喵OB�qN�F��Q4���4�^���d��4./�I��8�ic��F <-�V)J��~���"������?�G�{N&4Wd�Ɍ��7(M~�0�dZ��Ea��ǿ?���X�]j�����\����E������+��BM��T������۪���Ք�q����sc�&����$��Zvoܲe�X"5ko!i�(��,�h�M:�Hp����HL��l\ �3�'���[��K����CpS����	\HD����l-���5s��Lߝ�DZ$�+	�_~���!ڗd�0�, ���@��
���U�9𜲭E�	��(y���Z��9ad���ϕ����x|s[�O9�����sQڧ�q�,oHUwe�8�{�j��5��dd;�d�k~_�����t3�X"q�_G�Nq��-m��F�ůq��QK)C98�JȬe:J�αh�>i�|�>�޸X�kσ��cJ�m�$�
H��H@FH�$�S!|$��j�HnX�~�o�\���(�	W�~$����O�������s��d��Ow��=>p|{(���?��ocAnЂ���'���k�|u<���q^!�lb��i*�~�f�(no�����j��io�?���?B֤��~�.d8`AOT���P\�Q#s*���]9��bj�1�\���-+��P��UHH�BSVM�s��	*2ML�RI��=���23[I9+��r6���8<No��-A��O%���4a�\{��"O�4
������i�B��8�uD)����&�m�W!�Y��9���j0��HZ�g	PTD
�DN�.��b�b��������N�����*sW��P!��ط��Ɍ�Fܕ��������fJ�|f��R����X�-v*���S�	Ռ��B
�DBG�x�9A|��3�?�̣�O������a�� �����b�d�TI�Oˋ+�t� �l2
W��X$Ër0���,��Pvj&�|>�����/�ߵSc��L�T����4`���]���@2�vlf��lZܙ�c�����4@:/'�.��j*�N�������R��V6�GT�]f�fJ~����DҀ;�M��s��.���av|;Y¹N��䶮�FM�GI���b�D�����{��5ZI*hX��6?��!����e4Ѧ���;��^?T��qQM0i��z|s-�ۇ��<�1�g7����?�L��m(���
%�;��6�e۷!�m2�yy���Q���|x�1�O�ן�9A!���r���y|z&�8�QtNϽNβ>�ږ�&�4���2��&��B~
�!�*�A�#y�D;��B���0�~��{!z�ڑ
�`SvˆR�(�h}�Yo�D6�E<�긾��!k����S�y�d�#�k�P��o������⼚eU��v_��ʾ��Pj_H�H��3<�(p�aB8���I_� 0�7ё��+��i�6��fZ �G�N��gA�����d��f�m�,'�
쥥'� �EV�p]���WM��x\
��:t���A"K=�#�	^Kx.����G�����/Qh�:� G�r���M^8�+���}��	�<H#͝PU���J+�V��>L	����.�$����׼�����m8�b� �qKB�� 	2��������Id�Lpg,a�*^_�`Gʃ�ϣO5��Ӥ���eE�ޠ������hC*~������+����M���ؖ�~��������y~\�>��(%7S�N�,��8�c#��Q/+zo����$�����������йmt)�n���D�iu�����|H�ƥ�_��6��>�̚�˅X݌Ճ,��R-kj~��q�;�K�����%����]J�9�]N6��!�03}���3z+dnJ�g4-/�t8�_�r7枋��F�r6�+~��^=���S�|>�K?��Ҫi�Oh��"6��j��dbK%Y[+SlG8�K�S^�5moeJ���ʲ�.��"��t���r�ݎ�[�R�^���=J�[d���*>M�2�\�Ո�KK�d���̆���`��8��o��*G߈C����z[[u����66�F�x�c�4V�*.O�(������NJ\��T#�&��,����*��yV^�������,�    ��r�%���I����E֢�����i�8"��#�	�83%<�i���Md ���pOqZ�p���ÿ;K��9<e��K�F9�,���8���帮��xY rV�����y�)���Z><��r�Kڞ�~��3�ݪ��mUe�V����\�=��Tt0��x��F�5-����e��a�c$�����+�|w�������m����o	�f�YV�W)�%ݜ�h�[K:�s��LAV^H!���i
!=)�h�y2��i��:uJ�oI���K��j�JR֮O��e�)�Nx>�PD!����#)�D�7kfۅΛ�3��՟�/�e�F=�sp]�[3�w�s��֊*^����oC��?[m��/���q�OW��4�_�<����o_@#3T�j�8�1���ҒC��,6qD[��Jx�kǘ��8q}u�E��="�wЈ����&�����V"�Q��}U�=4q4�jJ�fyW"N���8�;��b�
..�-X�Om���1Sƕd|�ۅ�듢�̔�5q��SM��"����&g^dD8_�F
c����tQ��C+��V�mz�����L���RH������4^�`��p�%xM�g\��L\1��x:zgP�>Z��}9��Uʢu���]P�E��dJ+�����;R�	SJܗbrW���dN��-V�՟C�:���Шt/|��t!�/�P�G"
�'�S�yTB�پ��Q��ܛ,�����(�;{KN����/|<�D�F��]e�go�0g[��dt��Y�x�e�o�׸��r߀���,����B^`�`������w�8j֝:l�%~�P���}�O��7Oǯ��6����9�����yX<���m�6ܔ�Z�_�ǁ�N��>3�
�0���S�w�0�D7���ξ��L�F���7rI���qK����(�m�i�LZ��d�I���2�J�V���s�4��ò�M�����ֵpG�dN�VT��AC�"_p�<H����p6��W��l��Mj�gP~B���l�~y���PT#)��#+��у[����Np�{����;t:�{���|��4�/��m��=��P�wE7�]bh�7{��� 5؟�����^�L�o��w�y���5�w�|{2����[^<͗�a<�[n4���/���M�����\b��#7'P���fS��4���)�5��"���e�� �YY�$��`��\�Oc7���C�0��g�����Imʭ�6���;���T[)#��*��@X(�v����� 1|�.�Y}��%8�jn�!��K��ܥ�����Y�h��f�:�~��>���s��:�4��kט��Ik���E�YE��jF�P�im��_�
�uz��l��ھ�1qY��g�(�|�KdH�T�Q� Y����Y}��ߗRA�2q'ԤYP��\����$�|B+3�%)�Rf)�	H��17�d�=גaK���u���9���y$TQ��g��"F|�2@�;K��:m=a��ic��Vvш�-��'e�>̴�\�Yi�PΊ��9�out%哂I$�ˋ�R�C�E���|<��'�fp�Zr1��u{G����C�/\�3mH�~A�4$c�o30�+vK����89~}�/��gx����y���q�Wb�?�k��C2�����5�o�1ڞ�-3�Mr��PIub�#Kع��E�lDVC��Y;{�@��t��O�פ�j���?�J!1��>f�\	��kE�1��Og�k.f�>��+�qbu�e��?�������wT��Arf�vʣ�����{>3�� ��h���C�?k�Pu�eSⶌ ��)5&��� �����l;�a��L��4�I�4��u�jU �	�4�Ǽ���|��f�
�=ȑ�1��3��w�3@��5�O\���?L���!"�F��kPm8�$"A 9�B�6`�qU�ydE+՝V����{+����J���,\���g�03�`"8��v���%F!�2'���o�҆vg���+����L_f����QȺg`��$��V=.qg��ā3����p�?��F���`��FF� d�
�q#���RSe�Q)�Nѡ�K�0G�d��W�O��.?�N?�3����K���{����0���S~O�%�����j�q�l5i��z��mT��>�ޞ��-ˈ{�j!���1�=����=I��p���(�5$�f'����g����0�ی9��R���*���UX�q$cN�9�S�:;�g�¿������as��2����Jp��f~��a%݊������w�X	o���i���
�F�7AOX��ϵ��2?~-n�����ceh(����^f���!��};y��]�,����.��\K�������Pm�8�\�|d�Do�G��� ޯ\=3ap�N���C���8 ?���X&v�̵�l�F�v��;�E�������1i����A�P�l�n��T���.�{��OO�U�OƳ�Z�K����ɃY��[ջ�`��l7�k�ts�[�x~;<Ÿ����́��T����:-�EQ��|!�!���t�F�w��};Jb��\�N��	4���R��Q�Ýu� O���ض4��Xv=���k�~>1�?@��T�V);CN�EC��~aG��xU��S1pp��P�KY���P��S\�9�#"�H��a]���|���Z(_� �	�U.��w'�����_�4�Ԟp������H��'+���d)p�9O�t5��N_����kv�a��W����2�'�(�v��A�exK>S�!J�Z+dh�;�bL�H�4�M7M	�)��\�T��#�'��/��6?~ϊ�q���/U}����Ǜ���G����0u����<!�яz�O��'��������؏
7�Z�كTj���?����������<�k�Lo�)���7�睲u!���N9\�4����b�%��K��)�Z�Y#�x޴E�Q��Oc��OE����N��U'�Ư>N��AD �JJ�.%\�k��|(B���i(Ee���)�s��k����X�9*8A	D[��~�#2��9���*^6����iE�u�JX�  ��t�H}:Y�7��kxH�cPp!x���q�A�Ȩ���5F��X�*�f��A�vng��ȭ���׮q6:{I�E��JY�ڀ����<:�&W�(��|;x�|_(�wg�X���+�4�O�M�8�m���V��n�C�����r�|R&�(c��{w���Q��D��pF��K#�� >78�2E4�k<�׬E��x���u�j����]e�kޠL~g��5��� ��ީ�̆���L�R-��^WQZNfL���'��\�@�hҎTq��̙Z�9�i�X�X��~X.=⺝�)[h�hS��Z�Ķ���BCp�>^�ƫ��uO{4��i�l]��|I��>���s�G�v���ǫq�Ak��~�߮Ƕ�u�O���-�o���-�Mr-������5uè̆�yV�rtF�o��״�.�ۃ�#�����Z��e0~�M��+���I��ia�燂P݊�B��|	��{B��V«E�)����mT�ML�&��y��GiO��yV�ӄ���P�%�b��!)F�Å���G�O%d�/�w|�î��l��>���X�jl��<��P*�(N�Ƅ��"&U�qdh;"���1�]�ZNv"�n��ߵ̲�:[�u�Jq����<\�I�H���C�B8g��P�u[�ͮ�o��2��gEo�^ɐP�0�n�B9M"n�����4̋B�(������{���V��X���s#z۩e�:]��`k���K��Fu�Af< ���"f�K�9������p]����"�ߙv��V�w��X�k!�
��X��;Ҭ]Yoӏ��/7�B����,ʴ�d)̱��fvzU"_L:��ܴN�Q��Ev@�я���G�9#�['<�Տ��zR*��a�VB��B�>�G;	?S��k��N�q�;Z@����Ze��7d2��TB$�����<.c��N\�\d� aCɞ_���7�E�s�iR���9eH�0�OH��_��V6kb2k��-�;'�	�    �S>,�_V������0�˛|e��2���{Ş�7�{z#��f�κe1ϟn�^�b���Hlo��~�(�Ξ�wE;��v��\�+F�3HB։;[�ëyÕ[z{���j0B���N�����]����6e�dL\ϧ���ަ�����8�1e�HI�w�^��w�� 2�1�a
K3Y�?2��
�Q���S�������5���j���j��"����{.lū?��۲xί��9/�S l�Ͻ�U�(B;�ږ|�Ƿ&ٯ3��=މɽ�Qs���iq=].k.�r��Ʒ�w��Oo�������2���)�ۼ��?�iI�������������힧�݁�~՟�Z����:�S�����5{��H��|���/�s��[۾»�U����b�D���Ბ�w֢��Z�qr<}����z�..�yܤ��j�0��?
����,_HY�Ǖ��O����M��xK�*ۍkߔ��������V����݇���N໼���샿?L�#�����-'O5|�x��?�x���|�[�- Ӵ>#ؕJ���^~���u�u\"{�d�l�=	�����@&vLo������1��c6�kɦJ�Է��?f�TG����ţ�TИ�/�c/��y�,ވ<e�O//��<�TI�7y<H�Ep;��7��ν��g�m�׽����s���7�:��rȶ}-��S'�?���0+��K�S(���$���ƥ��FR�Bُ���9��PX��K{�cAť��*����J需����='BεoU����G�Ui��e�l:Q��D��
�t��\Q&C��zc��m��b�b8b����M�H�z��.���i�f"ԽA0!���s�IU���0�Њ�h��9���o�g�C7���E����L��+�Rpt5BQ�-s�I�ɺ�����:��evYf��3��8e�.;�� �!�5V
�{�2A<�5g���v =��2s]�@uA��:�/YR�`g�����E����YZPy0F�d=y��Au��*�*誕2"����0�,@?�"�58	�UԹ#�4�K������H�d}(���s����"&Fa�b"�E��DI�	��E� ��5Dp�<1��;��{wvz�ÿ��L�,�4�?�ch<F-�� %k�HZ��N��Lr*��!���"eu'���[��sQ��⼿���j�����4}Öu��%��
&C�0ˢ��b��P�t�.��V����هb���x���^3N(��ܯ��<����r���~�r���/��W�`x�N��&��%-��\.��n�H��vz��.��C���D��������7��6��U�J!M`=�l�V���H��?mF�j��\����WH��Γ!��J4Z����3��D�Ӌ:+��6I�|���^f㛇Y�z���qI�\�Ɲp��]*�Z��c� "��@)eZ���!��R>o.�aW�����4�|Y?/����Nbn��uMɟ����|�L9^�t2��,ʢ*�rȳ�-$d��l��0�*�,�ǐY�Ҧ7�J6�@�@�p�b.uŧHl���:�lc��ן ۸���@T�ç�c8����݈<8~t U(��>��ʗ,"(�!���v��b���+�mo��x=-��%Td���>ͳFd�z�p��c�Y��B�U��;�R��p�L���E*��� ]R���B�`�����}z&8�V��Gz7O�7�V��MUڏ�����F�[\'��װbIJ���p�1��3��.i��Rg�=��_ջ_��H�����<��0�O�P��:�o	c�>B��?-="Lo�ԃ�ȿ��m�zC��w�v�A*$�TbH��v|��������;@$�������ܟ��,����>X[-�������)�����l�1�aC܉��H��Io1)+/j��	�۬���k�p-,g�����lv���C���>�3�z��g�ww��e����T3���$��Q(���r�}X9w�!(JN��-�9K�i3/A�l�&�,��U�.�t豴>E���v��y�ȇ>g#.%��v��XM���"Cb�Y�Q��{a�9B�ƶ���։3�*���Z\��[ ��"�MY�B�>�y������o؅��u`��q��u����a^M4�������l5�ҫI3�܊�����Q�}:���*�u��.ҲZe.l���ήr����i����p�~ꧮ�t��>q{NF>�(�:�Q�c��,4ڳ^diDU�}bC,��P�gj��P)�EOh��dxQee�HN�W��h�GXJ�2�Q���~�r����ՉJ�������s�t�Mj?иH�E���z^�1c ��#e:3*jw��A�qK�p��,+�y�R䮂��k���4��|^��9��Iy.!�ZCe�6���-u��Y�:�^�e�|	�#B��`�ZQ'"̫j��{A	nǷ�k�}3�n�n.l��U~�C��ް?�u��P"^*^289�c�go�0�3��kg�:��C?n�����6�8_
�٤���@��*+�ន���H)ٞdR���&1� )�O�oTT.J��\�J�7;���>��:�ᱡ�H�(�:~���Ғl��e1���F�OX�vIf��׎h��T�i0O������
 ����_��������[f��e�녍-[ƶ�͟�ӷ��������W�"�̲9���ï�%�OQ=�+��b^X���r��(V���B�@�.�"�1���j���f��){!�T�Q9$TW���~�(Q*;C���t��C�^-��}I?�7kj�f7p�jQ�E>���G9 �>�9��6D㻦k��D���_��uZ��d���T6�����3���t��2�Q�S��Ew�_}���S�'K�i*e����5O3B�<�D]8�ZY(������ߜ��g�q���U5�L�W����|矧ZT���e�[����鞭�9$6e:W��I�.)����C=��6=�e����?KSɌ��mVh�u*b�
�m(�O�$�E����<Rh����6L#? �H��a=R�_�~�2�ЯD���P�E܈4���;��(���@E�ٙ`U�L	2���P��8�T��n�	�0��"d�6G���t�׏��d����{Z�_�������ې����S�j�>��w�㻧�w��[5��ӽ�5����2�3���+�R�V�����>y�a��ڑ��܎�0�l5r����B�]f��L	"UyU5���g?,!}��m�;u�#�a�s>|�W�&4��@u݁Y�������Ր��5�S6��{G���(ɛ�_z7ؙm59��ox/[Q�a���9�.��F��y�[�t�)�������l��h�ޟ������Ű9�-=�>�H�:�S�"�NkKmH G�����³�j���(�Y�lg����eR�M�L���CVTp�
�bS��u�{�U\Ư�i����i}uP����xkls�����`�=�Pp_B����Bk��X��eN�~D"�OClȘϏ����Ͷq�q�M˱Yܓ�#W'T��r�ݾY9y��XhNV���4�������S�@��B��]O�O�xxX��^C޸����ՠ���-��f�������/7��W7������VΤ��ۄ`��u=P����:���7*x3��/��l��5E�*����vz��ƌ~<��g����7�Z33�1x~D�c��$���"
{�L;�z���b"�D�h0��9:�]ͳ�9)a�B48��x�I����*]�o��;�wu66�_U���B�f)�;(�(c�D� A���t�˨�$:���,�lMna�\��[�V�a�G6�uL�:�rԀ(�7\�RVV�<�/дN���
�n�y�'���,0�P�]����>c9�C1*�P�<�����v١���%�*���KNO��.ݴB�|eZ^4���4Cx��(8��Í����@D�i��]vi���2k�H�]�m�P�0Q!p�׋�/���Ā�lUFߨzn������Ff�$��s��R��^�p���    �`���|�)mpBur�L:�wإ�s�?r�(%��2��D2��q\��QB}G|I��{y��a����2���Ө�K�$��mPw	��!6s�E\^,�aRF��M�]�t��}6i�&?�
����R)�R	Op�=��G��GB�����Nr��%~"z�/�>�ڹHPy6�P�El(&5.�-)�Iy��� +��Kn���l�W�<�d�`j�u�q�,TF,��rK� �'�P�3�Qv�}G=��(�ZٛQ�e���S�#�a1��J�fZ(��[�W��y���_��a���(7�b����m�٧�e���Bv&$~�Z2�|)��dƾ��(�Q�:���
㎥���>鉤�����\�eV����NB_�j��%B_8�>_��������s��u��+�}�P�0!: 0LF&4��ȣ��ir�[�:i9��f���^<��������y��BS)icz�;���:��ങ�g�ϣ3��b�z�׸�3��b�SV]6���P���O�(���h��� ����jg=޸�<���HI��
�W��n���6�F7�z������Z�6J�[f�MkI��RG��|�k�-YgE�S�aN�RO���l�0���l��d}���m�^������J���$d��h��	mѥ�mu����u��Ft�_�������G�k��:��D�>���g��3�}v� ��P�AHB�K)�y |_IÝ�|äy8����B�c���)z�^�Ü�����i�u�z��z.q�5�z%eg��3�s���l��������\�rԎ��0�7['#�^���HD%�ܧ>�<R��M3g-��#�'���D�?U�a��P�՟��c����ân��ӫ����0�;�eW�&������ۊ�>G�BBކ�`�R/d>�ў/��I��k� �#E����)��6��/PsB���~V�M��U�����Vq�=K׸O�c6��A3�|_سw�傌ec�e^<�׷��,��r�q�#����Xa�L�k�G�p��#?��?	�aV�,Y4ryH�����j7C�2�4�Y���7~��>� qn�7��6۶�g�)E�g¨�p��H=����pC#C���S��#��h�20[�2)jT�u+��Y��šA|�J$��L�:Yl4S����->E
�i1@
�a���0an�O�8�F�}Veq]����a���'N��(�|OY�Dx~`�AyG�
%���◴n���}dv��B���%���9Mp7��D�2�ȏ�._�Q*�QH��ҡ;����|�OȢ����G]��d�S:��!�[{�ix̀Z�#�p�������2^��l���\ظUŶ+ֿ��|� \����q6~���|������	�� �������LUc�h��դ*�z�~^�ɏ�B�Yf�>���K�o��������^��v�w6���U�F��:s> �L�ָ5����\I��Y^����$��!��t%z���w��TH<��H����DH}��>�DbUh�0"�,��>���'F����KN��b�N�@������+X!NZ���%OF�"z��D�x^d������g�����P{R�)(E�����$��Hs����P�A�b�lKr�ٯ�@��{w�\��-��Ww���|E��!o�b��H�[%�@�@��@E�c�)��'pI���WʏL�X�}�._������IL�Sv�F��lB����&��%�?�9*Z{��9����Z'��x�H)���Hb*���A f������V�����޶-�FaO�&�%����.��9�K:��MjKFQѬ��'��D�s��uZf�����}kl��m�8�䁒��'V��\v�r����<B��u�uxdE���Z;w$P#���������Ks�y���!��"A13�i�+��H���/6�wg�8�|�`���5�9B#�5���)���BS�|�-��v6��H��@��|� ��S�͉�=�y/��syD���:�%v�%%��l쪈��Ew �^'�ϖ��w����3.��^RL(F-� �a��u����&:o72�^;������%eVz<fH��������O��*Y#9-X'�(!|R�N�&���T�I�jg+@*#)�|>�ta�h�Qx$�{�ۺ�_g��a�d��ӡ����J:h���P�J�z�^�_����@�`�����c=':D9c2x!	�@OFC��"�QG�#�s��;�������G�C���:��]��,q�����%G���A+�Ş^,�`wyX��DT?4�YTy���3X���{mN!�ڴ#m6<L;0��b�>a������K\Gu���^���?�?�T�Æv�NF���E��^��ҕoӿ�q&5�u*��=ӎ�`��R��>�Rq�h`|tbGJ�K�lG|$;�>�#�'���+��e��b6�(֤�T C�U���p=~Zħ��&;�>��m%��q�Fr�����x�Z���>�z��@�S"���
��D�xG���V��[��c��Ķ#f7�_�������w�m;^�����b�a2~�n9J�W��`7F���t>�c�S5�yZ,�j��A?ȶ�Sـ�~�x0��r�3h���oo��2^_B�� �i$b�2e�4�؆�̅�Y�(%s�m�d����1�Ų�[���-�$�lZ��D��tm�A	�X�-!����4�|���i��G���m��~����C�	���]z1��z1V�Ca�E���X�������o��F�[|�C�h���ن,�4\�,*Q�;�S)�a��s�����I�a<�|�7���:�1�!�AȌ�*��+
�8��>�[�����zk�g���^cH�c�U��{�c�|��gZ�/1r�P �@��m���.�L顸#�GL�]jzCL!�B����m�Y�7}�R�#);&����i< �8Ѳ?Y^�Q�6�+(1qc��RFUZ��QR%eT�fcvq(5;Y�7�2\ϙ-���H�FֶӡK�k%�q�&³�󨋘Q��������-q[�>�/����j6���K�Q(�� i,����E��<f���?�.�ا�<>�F�v�G�"�<�Ί0�UJk�p�V2�v���v�/v��P��J���*��%^���!h����K�PVƯ�([@U���?v�%��>I�T�L�M�K�(��RB��jJ�@�:�(�y$�~l�J��k���Ν%�PZ�Wık���U:�.�i<pI�l
�6��b\^�	��<Xj�d3��B+O��NB� 6�҇jG���ȷ�Im�`�	��o�m���t�г��h����[�C���[�e��V8wM!��N��j��qm1��T C�`xu0�N���.t�9�-��}�/%�"�2b�6�����ת��'��iü 
�#�:���W��o���#��>1i��x�A��⑈�d��t�!_-�0�	���it�\v.�$^�_`�2
����P�N��4L#�EzTF�Qd42��o�����4�F�8a����-��ͺU.w\�<�b���1e�|VtY.��.n��9�.���z�(W��U�Yi���㟚���U�f�=�V�`����j��������dC����$,LXHrz��N�>}I��ד���SG�;R�^?s���%�R��uę�k�YX ���4����Ah��m�7�]�m%n86�8���U�ӫ*��r�$�_4�t��`ɗ"�qxլ'F�,^W|c�]�O��ExcY�Uy�c�����c���#�V<
��tpA}�{�(k��"nՑ��X ���h��H�	J�>���\���'�I6J��!�˧�7��ģs\�Yy(�s�Egn���Ĺ�:�� �`��yV�@.�����G9Ho��m�zL4��_F�Ԇ���>�()�ԆWu�\X���(�?�B���UV#��*8�è��j�Fy�M�٤j�x�~�FA#<�M;�#�z�<B��L(c���K��I�߲�A�^�-��aE/���ֿ�l���x�c����Gɛ���(�Q=
    ��g��"ag��iH��r� G�Nt�H��g<q�-��v����NfŤ��Z~X,_�O�m�Q((R9ގ��P�Nj��W?=�;�Qe�08�DtP7ҭk�u�d%?Q��E�8p�:)�_P�*-�\����3J]�` ��f�8�/�ݝa��k,�8U��5&���D!���R�!B?
S���`sKu5����[`�ۛ[ʎ�\�w#���������3$
�4������W���%����_�[��FfwwK}�4W���ru;�g����Som�~��,�-�lӝ3����%��8f�?�{KP:g��ӦY~���l�Sx����C�
e��j����?��s2��"KNft_Ÿ��Ci�1%��G.
�?�����Z�dR,�2��XirW��ȕX���ﾲ�����M�'ws%!fL�ʘǒ�ϣɲ�O�j�\r5��U��6�Q�ն��N)Xw(A��АvA�Ũ�3�[dѣV��p�o��ءkܡ�g1�1�Q��#3ly�cv�o��_�:���@��x���K\�8o�����:�x��o����a�H�!�6j��)��рR"4ұ(��K��8���S�K�^�k��(�Į��]T��;���4��cz�aH�>���<���-�9��[��W,�	C�^�����|Oj�l8�n�N-�#%��6k�[d�7$���*N ��N]'u�H0�8|kH��:��h�0�4-�H�B�����3�+�(��j��z�b����8=XC�"�}�4�\;�f�Q)�od�}����o��C�0�5��f/�~d���֢�NY<�,��T6�����(�H��/����,�b0���ΐ>��O�)���ޙm����*bėJ(#<b�o��B�����G\s��SA*"���̜H��bt5�;���׫�w�ݠ���(�׳��߂��B�fT,˛كY=�|r}�t#�~  Ҽ�U;F��ấ�#����|�������q9~��M��f2�o�Ս�&~*u}��r�Ǜ�o�����V�U�m-�v���o�/�c5��wI5�K`�����ח��i6���&�q���?��"�q�{���2^�Ә��m��9K�^�9���n��M��>!�>w�� �l_%}�"n�
bz� �t�BqA�'����@\C	eM�`�d���,�צ1t���ܬ4�Pq*�����u����X�����@�1����@�S�j?��s~(�E~�"jxD@}�� ƚ͜-����CvBd��t1�]N�LYF��ɸn�ė��VY����'.���+�d ۬�TyuSL�|��^����q��[���pYa�;1�	,g�L�9���yN��R�2��(�r��K<�*������6ih5�?�>\ߎ��Q��Y�J�in)B�Z���NۈxT;�"0��L)J\�)�#��M���vp�Џ�"h@��@1K� L.Y#�J����l�W��E��p���bpzUf��[Z��i'h`֘�M^<><�ӛ��6��ܥ�Q蜓� �����POT�ȧRQcM�<_���M�pr�O'�GjO8�oX���:��@��7l���~����*��"]�tVTl��Q��(��!�s[;�&~w���RZ�*F��& o�l�V�����ԏQ�4��PmfӼ����������ΓHC���k�Rrz&q6"L5Zd���%���J��\���.�,�l���u1߻�t�u��+�iG��>B*ȠB��j��2�x����==S����{��~xUǣd�f�t�3�+6�QVU~�{���i�I՞�q'-gH��d� ~� $��~$�e�8���_7V��̾IC�M�"M��¦�Q�kf��������az7>�C�ͦ�,�3��^���>2�yE���Г��a���~}_=hY}�i��Jl8�M��)�	-z˽�m�1O�g���<i��̽3�
�E�*���y�ܻ8�Ix��W7����,��I������qy����G�w%3��2�T�Ca��4{��os]�s&�}d/���R�0*@��h�38�d����b��%���rZ�t(F8H�L��Y��Y8�<��Q ڡ�TЕ��0�C�=$J��CN��!$���n1�oR?�(w~I~Bdom��>'Y����r�C҈֮��F]�t=�ݯ������h����!��B��^C�}�����lr���D�}YfӁ݈�����5ZI���od�R���_���7��O;[���;�qۏS�
-^�c�`��7lާ��pQ�%�.y\�<E�fyrv����t�j�Q��L3R�G]�CN�`w����A`%c�/��yĬmْ�Zg�8�V��%s�Z?P�o��}��f�1`8���f���S�wY�ŧj���{��7�
Ya/a� ->@���K����R��I���b���6ڥC8TRL;�Ӑ�_���>��n���4=X�vn�	��\k�I�Oq�o���c���o�qB��D$C�K��$��LVw)�Fa����v��z:MO�w RxC���. ���#��%���<��WP�aS|s��"FZ��ť!�R@�~��uZ6DT7�������y����w�Ri"��N�ʭ���}~�г4�8g���)G��m~{7{x\�����-�7еB�I��~{n����u��S���؝�B��Q��F���2��A&��=��v���Ncz�V!Y�s�Y����O!՞�
$�;�+�#N��:�����*U���9��GU��5��:A2�:$�Mʆ����U�����9���K]v�\�l�� �W��|���d��)�qLs҅��gzZ��RP��9Xj\h�']x$�~]��r�ko[%���'�X/�i�i��/!�[}���&V/X�'��iVd�������L�������=�[�3ڡ��Q
���}����3�����1��1�]�����b��Gr��y6�i�{��P"�)@H{���K�i'��E��s���
�%�fT|���*�B�Z᷋J��j�NJB."/�<bR;-�@y�d7S�ܪ[�I6�GNO��q�O
�U<��ؽ���+I�f[V_���\��:C�Ϊ�sc�p,���ٶs�g�=����b�K"�����2H+-)g�[%\�f-� �����a>ub���Ӡ���ﱂ����?g�I�˧��ۻ�4u�Fi�k��avo���]�7�XQ}co��N��k>�O��A*wr�|E��2���d��Ww"Z6��%���/b���"x)�Ԭ��1k�R_E2J_.������Q���'�fWf���-�'��4�b�kZTEQ|�R�-
��Hwcb��^�buT�e���"�M��"M�b����+��0�8�8XQW���6�wz���+j�s�*=0Q�Ɛ�Hc5��2�0��#֪����g����6
�ʏ\��؟1����ۻ�<�o��]��������H�0�H���R��>E��x���\���%��dfns��@ebM7ܖ���TpHThO���F�%6�IVz�dx���v<�ߚy��|5]���������0w줂���wS��>��<�
\R�Iǈ���/�����2�>�<�#e�eO��Ş���)�G�OL\pb�)T7�O��=��Ȧ�v���"�(gN��Au��.�էtS~?�%��EY=͟��*˪�0E<m,�F�z#�G��Z[�w|_h�SK����%=���^���7�|�0��I�a��+o��{y��g�'Ȩ9�f��i����BrT�9/�5��C�	� �nяG�{���HZ�k�q��R�7"��'^NL ����T����(�3n��R4T����^��Y9��[#3�9m���d&����e��^�5� ,>���ݤM����nAz쳳�7�b&2���T2�>�>d���x���ʐi��x�0�>D^����x`�����嫴NozUBR���+<��0���k0J���vM+G�wD^[%�z��Ày����E]���=e��ʨ�3d�%?b��6�8��U���5�u�0{1�_��T'��|�����K��;��G��F\    g��>g�՛���w�_y�L������?������q��_s̑Ћ��x�2R#ӡ����j(P*4��	�h�e���8!8�
ʜH۟n��S�m;���"�Zd���:J��g8+Z$kd?�Z��!�w)��Q.�b�����?aH)\(�@�Nz��"��Uh���0>���I\���#���,uh�������/�1��\�N��_SJ��Vh�}�_�2~�Η����Cؗ��_
��'�(�L%���B�.,^�&��(}(P�W�SI��e²"�n�{B��M��h�%�go�*5��#����/0�xh�06�P�����^`��؏C*��|�؊Oo�\�X���������ǻz|�Z���ks�Z�.�9����|�]s����@����9$n�]�$�� ����I�/���s:�++k-�Os�qy����(n�J��gp���d#!�~��Y��|2��t�����I �"r@��q�0��%��������Ck������ ��_%�~�G#��Ѳ4�QʲT�|���w���CZo�H>"��86ǿ�������k�O�~z�#��f�
�"�����$||C9�̫~%�%-h��<ח���6���}?�'q꾨H�_�H�W0ˣd$뱛�͆�����Ƅ?.�3�xW����S�--�6�vײ]muE�r�Pv���Q�(�0~AM�T�O�F������s
��n8r�N���
&��U����!�@�H�@�"z�?l��O�˂��(��m��������*�0�+��v����.�>�y��7>r>���0北����� F���#$E��:�9�}���rt4��X����`v�~O�K �n�.�G��c��1�ӵy[tm�%�t)��t;�E��v�Ċyu��|����#D�6���@���	�n<@�!�·�s精s�����˛��#�nP��@�4�̫cLS�\Z��RJX�hWC\��Q`��&��b�@�L^6P~d���B�3j��7�F��Q*�ID�]�!�2��п�GW��_�z�h�4Z�Yg"m;R(ݵ�-�ZF:Ā�B(������7m�Z��-�o�].Ћ�u����|TW�7Wע���xx,����0H�|����t����U��-�`5Y�9+�V�r��ز^�O���!�H�Ay�&��F�ݶ⪫;FW��?e����L�:�ʜO�*F��W�e�b|N
�x��9�4��H!���~4��he~�@��յ�*�.h e¯[\w�p�̆��ו�R`�̕��<�������!��T�l.���c$�Đ2y(P��'p��ᝏ� Wv��U?�+�k�M�9�7LA�	Bx%��\Yha�u$���%�-ۀ��6�1�0̺�Oì������g��e��	�o/�u�<&r��û�C����a�v�"�3h2�sҺ�����7L�uAn7�'�eB�l�8�l��Xh�u��_�Y�1j�v��'͋v%�?=�?�
�(�^HF�S�v�����^��D�l�a�a�3���p�e��0���fHc+̈́�g�鶹��m���6$?�*�ј� �����|�q ��'�9Ʒ� ��{8�%����N���-{���˦���z����p���4��p���mN�Q�-��J9mc�غݦ�����_=s���ݗD��n	.1�9��Cd�t�Bi`����ջ�ƽ�Q<�{�w����[#Q�������}��������_���
j������	c���RgK8�0���{�1)�@�p��7��|���!�O���oc��FsD������k���|��7�ͺ�v�U_�鴹e�PR��_�p�l�i*���?�l�VYfL���ِ�7wC޻��]a��:�Cgj�����M�����������6*6�l�9IS�SSY�7�%�OԱ�6�t�]��,���mW�n�Gi�Ai�ge��4���_`�#c����簴G�a�|b�B��i#�+S��i��F�0�e(Sg���
�1�$GqX����#k��77G�.k�j� `����a�~���7�u-S��hSÉB�}ΉKN�F����-�#;6�܎a��ۊ������������b��d�J�x�.�u�I5���1��OZ�ꐷ��%<���ķ�ܪDZ����f�H�?���Z�8(ଥ��d�C����?�[�AV���m�F������3�J����W���[�E��������'[���1	�b�2!MR�K3��v����?�Zu�vL�K�]��
P%rCHªKO/BՊǋ���m�i���K�Wɔe���"��D�w��	x�e�V����4�[�s|B�Wr2�G���"�dt�_�C�ȷP|
���j��%a���㉚K��h�uN�� B�����-�Gä����Ox�%CV�m�L�����8�3�c�x��G�ߊ�8�h�Ȓ�)��߯cds��1�h�ņ����7�<����^Ȕ2��2�M&4J,�=����[�넰>��	��bⅉ�>�VL�߇\رj��N[)���}���L��em�8�c7*P��N�k����Mtۮ+����<�>e�N(ʪ��jg>�A�O�,j>��f!U��YL���������$?�2�Y�:��Ekw@�(�XL� ^�wr�Iu��\Fb�?D��6��k.���_��'��%�Z��
ц�4�lĕ7����G��������h`�ܡ���Q��p�=�kzs7��P��W��ǒ�Q�c�"�Uj���.~�$�j�s����Ö���a4�C��\]�c�<<��_ؑ���> S��󂿠�F
�cv���A��OoS�#]*�[ϟd8u��,[�Fs�j-0��me��M�iK��
';��4�lNj����q����(xz���*�?p�}t�>���������wƸw�$N�]O�n��Z�e�����؝�f8gl�jA��j[�&yA��Y���qiaȊE#z)�~��7
зsqRҳ�{���'ayiFx|�+(�m�&��y>�<N5P�#�Zj�3��8'��,���8�$��ÙUʲu�q�����iqz�'=L[��&jM�)��S?[���"�t�Ǚ��L-��R�k����h[>O�ty�Y���˖�W�`��~����lJ�b|�'T�WN<�(�$m���CkwO#�����MB%�<���������m�$b����跞���I�#C���b������x��s$�����UL����h��'�8x���W��1�>�fK���^՘0��x�U�d���G�O���T����8��vy���qO�&Q���u0��f�I_,�\��|����ɾL��� ��<��b@ʍ�W.�X'_L��[���k��w�Vq�s�����g�����5�!T�y�$�aᄳf/?��ћ׈]T�g����3��*F�!�(��ҟ����{/N��$U�;z�����x^��ɦ��J�j��y�%qf��d7����ʹ���܌Ws���s8tN�]�����ƭh3��E�x�Y(�ZLS"��x�MX|�F�m��$�o��2�p�#e�V��u�2�:zO�����Q;X-pk5S�ϯ|�D�}���w<-��m6�S���v��di�NV�͇R�2*�<*����y�^����(��Y����bև��L�U��!��M��*��2)��?'o��ds�V�4ˀ�I���oOb�>�	Q������#��G��Ck�g��8����Qɗ	+�b��� �_�������!|�J֖|r^p]�{�%t?{�p��T�t�_���ts[�{��zG���چLy�f�$��4[��Ğ8-�`��>M���Sv�$)z�<��tdK�����3�oy��8�?��]X�~i���:O��r�/�V��D�Xi��[�'�*��:eGv1��7@��z���l�[�4�Z�I�'L6��|1�OiF�&W�0�0ߑ����.z��Ob��|m���1�+���%eO�����Yk�"�ׁ��H�V���׌Z��ά�'���k-�d#�j�z���پ�U��S�ҁ�J�i��?��<IZ�iph-|t Bz�t3    ��4���|:��$�������9)�5Mr8c�}��!��Tm�����iy�$mm�<���ֻP����+
�?������O���W��S,�������KV��<����H-Y"�&S�ŁϘ���!U��ϖ*'��åBĊ�%:#�75�^f|쯄ڬ�8�Rx�A	�-`��)����W��9��<'ϼ���£7�� �zA$s�m��2#�O�܁ǹ߫�I���C��{�����VU�A�2�����Ƅ��}�q�~���������ᰉ�0�k�N~mv�G�qp��z�-7�������(�6����>�_O�M��o��ދlz/I���Ǟ�����T\r"~�ͨ�7���DK`V�V�υ����ߊ�X}w��b��ǣ ����;懭���e,f�&�b+���&Q��b�����1S��|������6����������>��������O˧(����(D�%�i����K!�2�h�9�5�	;�J�b�j�T������������	g��`,�F�g��!��t�5x"�ˇ2�|Z~'��T�ߨ�Ix�tQ�E�n��l��x���rǸ��q���d��W��S�ۉSGRh��W���[���N���b�G�0��r��q�`�Yt&{p@�^>�o�ǌٷJ����s�����^z�D�G�K���zt[_�s꜌2�"��Ft���|�te�s+8��H��.�Q��.�m�rL��I��hB_r^�^}��9�}v-�����i^Gpzv�ȁPSz����o���G�WsC!�#�k��f� ��{����}���mY?�$
C$Q��y�,\.�[�'$��e�����Fq�3��"��0d=�:�o���Z~��ӏmо'7���sz�����N�Q��s���/�ǜ���Im���~P�2cs˒L0�ଶ0.o+C��j�`��da���?�(_�����b��Q�|�����
�r������N�#;{��9�>�G��b�����?u��Zb�윬4�F�,��Z����`ۮ�3ٵ�t\�R�����,"�����M���P��K�_�[���^p���ðHi�R�U<k��M���ޟ�E�2ʹI���k�q�g�E��5r%6b�T����Ԣ4�~�(IҹZf�؇�<|�Xio�仢Cy�`'
���XC��Q����KP�q��R�u;���Xj+���Ix��K}>�a���o�8�nH�LG���t��_��w觮9���WM>Gg��A�-���A��L_�Ǳ�2��3L�t,Uƅ��D�y��$MD�/W�x:fʐ3E��[̴�uOwX�5�v�ӎqU�������v�J���lt��љ��ҧΔz6gꌒ�A;2d�t92���o8��~Mo�[ҏ�F��cr=�3M�1��B�,~Ǚn���#��u�M��E���R�h����,��
t�Z,뜩$o�Rij1����E��VW�3G���I��F�v�b6+�u�B^�Z�@g^H��\^�M��u�<K[q�E�ك���lB�f�ջ 1+�����\�G��|]Ύ�xE�r�'%|��G�ُQ'��(�����I����侵Z�Yk * gf�V�z��a�I���p�KA��S����f�������p<>y�5�^����b�T�^h���Q��t�a/�k����^�ē렢��{�s�Σ���`��:�p��Ck���[���X��|��t;�6�\��Z��t�\�.��V/���IZ�
���<?	qI��Ѭv���u8mmf�d�L��#�,`Kk6����Q�%�[���私���٩f����E������t5eI�A3T�`�t���t�5�f�ܲ�؜ʱX?؜��{����)o��8��pt��!�L���yj	Ƃ��2Pyrb�FX�(��u�v�I#L �QU]clαKy>~���<���A�R�o
��9���.W_�^:�G6���{���ʃ�8�h����Q!�#	̕^bT9Wx� RlC�؉k�]hl��h�uR�b#���h�Cx�͛�{����KZ�uk;����Ív��k 4�u�+/|Q�/��V��d���޷����oWx��Q��l&�B�T��b��\(��J^~�T�����[�@ʗTf�|�����=��V�V29�Z^���`��YI6ZQ����k�gA��J�/�z�g��!�*g����o]RZ�_���ǽ}����ڇ���A@P{�?zN"o���a���"O?�o�V	�Te�K~�7��c���>d�I�u�DK�XCH�J��Ώu�eF�|S9:�䖊��J��&ߤ9q��v$|���$��Xka�]PYy�g%�B�*�
�� �g�&�`����M�	4Sd�3壁�ﰰ�Gi��Q
���Y*+b���X��2fS�)<�^c�XI�JV<�����)씄��+���zNc⇉^����⎓�������>�G,i��j��Q�c�x��ǐe{�Ua�j鷇/w(��10�� ��V��,�
��(X'�q�7L�gB���a�9�U ֒l�1DZz�ڣs5炅&������԰�Kl������ؔ������KF:��"e�v��^�Zv��|^��().B?Qsij�m^�E����qk�0À+U�DO��4�[t=[l�f3O�S�k���ݫ�}�ֆ��GM���w)�����8j-ñ��=�����K�4ԛ�,��;f|y"�4��.V��4�b�J�%��c%>qq	[�|Xb�"��0��7w��d����P��{<L��ޕ�z�����Q	rݲ"��x}�`>	~�?�"���u�p*j�6ñ����e���u-pEo�Q����F�L��o�ulKh���kb]GkA�� ��� A�.������K#^�R��Z�m8nm&�ϱ��YDv[o�&~0��"����]ʬ�]Z���İf��GE�=ª�u),v6�b
��5a����φ���5��oy/��/z~N ���w�a�Y�4�
�#��=�e�K�V!N��I,x��ޗ�G��kx�!��k�(+�C9u�e�.�ʭߣ��]-��-a[ؗ�CcK��튎�勆x�(_�(5>._X����&ak5]�Z�� Ogs*��6����7$"됄���|QBT���nS_Y����^�&�E
ƭY�Zy��sab���V4���h�g�5�����k��+>�������+B�.�fv���O�Ak���V�D1��V��e��[G;�ّm�=�6�!Z}W����:���߳���g�}ֺ����4
�R�YS��I�ԟ-*��/���^޸�^�酋�x����=..�8}�{���wY+}����['�re�6�|�kw&�5Ͷ���c���\�1��v�����*!II1���$�%W������|B��8������3$�!5����E��$˰����L��G�v�V�}m鳓$��V�
JL=�UYv���0x>��E�;.m�8�hK�Ҋ���Ǝ+N�OX`Ѓ��s�h���Vb��cCv���0n��ArF���?m��eDpk!�`,a�S�7�K�qX#L%�燉%6q�!�#1�<S�&,X1�����`��q �r����|Zw��+��U�㶥ͻ�v�N���&�8��3>K;�%���d߁M���� �u+���c�7�0v��TE>�H�	��1�sX��?[�����JC���xK�y4S�c� ؈�q�Z�>�z��%sE�2��w�N�c�e��H��
T��^WȎp��:�v;�M܎$�+iGxE���ֈ���/Z�z����3���l�VV�K�b��k2�fMAh�z��BY�u�" )�\�r�ypDr��[\@�x��/�<���:�J��-���$\��.���.˃-.+*W}B(�H?�9+�ߖ�Yy��'������W�U���d��:c���	ƫY��o�|���q�{p�~�תU��4f�����2���n�N'��z����n�QK�f�3Cv� �}�;��e�u��U?�ݹ�ݹQ�ő����7ܨ%2"��.�X��,z�\�+�%���ĢE0�Іֺ��r��Q��u�5�VLHKY    T�Jt5���k�� X�6�skk��� ��RM�63����> �~/nG��O���o_��dfW�ָ�9��0�L�����3Z%�ʣ B�`	��%j�Ivɗ���^q�"��*/��:9Ft��4��R��M[J���툮�r���6�C��^~ze��_�-p�Y//��!��8J�)��l��Vt3��Y�7'z��<�^�	�c�qޠ�I�ψ��X�+���X-:�X���(v�\%�@=:F�Zj	�q��0�G,v:�6�7����Z��I|�0�|�y������'A��������}�����_��P�Qw�ˆQ����A�kI��2c/�.��:TbK��6KƳ�bG�t6KN3���V��O�y�ͮ�������K���b6iE���u��i1oQ��f����۬,�µ�v��]S��O��uǫ/�+���MYr_��>��[�(���[y�nWs"���D�f��ߦ���W_^Ʈ^���N3s����1+����鵡�շ�� 2|�9�Db7W�9d��)�?|o���(%���!��aiB���.���1��&&>�U�f��F(?���,�����U@I��%l~��	6�.q�BQxj�#:��8�ڶ���#.i�ES�%��q�[�"9Ci���~|��;	ġݨ����E�
:��ƞ���O������+Ds�^6/
Ja��v�Ͱ�o�L)��,�U�|0SC�+�8�b�4Xbl��e�<+o+D�v�K�e]Q?uMPܙ��qH�-Ѷ�0�AD��Q�B�F{�d�O3=V ����n�o�?H���:�./8,�Meo0̇H�1�|�z���A�$ꅙ��#I���(K �Z"`��L�dY���K�Ly�X�(&��0��%��a����P9 �v���uG[����Kw!���B�z�X��	�B����C���M�r{��;D�S� ���O�h�K���a���Ő]�Ys`\+t��V�6�!�C�z��$���wD�ˌ#��mMk�����Z]�ˤ���J�Zn���!�QR0h�羨Ѣ�8TԄ᯦�j�}�=9^>������w�������>���G�7�G��Y���iR=gpRG[O�:��4��7+�B�Y���^'���@�{^��<�ׁ���$K��*ȢO�`z��nd�숮m	�1ơJc8q]n[C�ҹPV}��b��!��c�B�>�����.�Z��^t�wa�S�[ܻ�v�[��t���,�ۅ�ǭ\><�snW�ūW}�.��ta�%�G�.d�K��Q�4MZ�n��f�fzY�,��bE�:He:�/&�X�
�-��^�I#GԎ)�@%১�G��x�X|��^�Lֹ`�yk˟���9��X1Q�����У*����T�Е^2y>ƠA1�${q��������	1A<d��u�����i��ۡ����+��T%��WW�E<��۰��?/f�7�|��f�+
�+�g��w�_���$�IJf���j�6|��#,m$!�l�ɨp;E�i����XvŚ+���:����A��V��j�87m	�.�t�w�U��*�Á�)A��5���t3D��1�!b�h�[�l5���P��LYO�ه~+��<������?h��������2�)��9'~�4���\Q%H�_=H&�1+��"�
� �Ly+ܩ�ֵ5�6��ڄ�]�dCiNj[�ƵU��fm֤��Qmz�k��A�젅�� �RF�JQ�e{3��;��b�P�oh��g���	��MN�dVy�zݧ/� 
���h�=�Pp���%%�\��z���TES�,�����GsTJ?Uw?m���}k��DN�������d�	d*�������^��O[:u��8�Y7�ʱUGj��_�v��)� ����]��B'�t��K�݆l��S������}�
kĩ/�m����?��B�i �@ŭk�2N�m%a�eO�QX���$=h�/LȗX���[�,@h5�(��*��X����З���pњ��V��OJ&�2�ε��ӥ'=�O2=M�M����|��4��˼��Ǻ$%dwEҳH�b�M =���b�����+�N��7�W}vi�`��K��%ACqi[2�&~�-6�x��|�.�r1�-�V���K�us:'^+�).m�2=�r�X���s�Y�E|ӥU��l��%���bI��c�uvh���l��-B�[+�˹�[�p��>�yڮ�`�^��=����()�)ݭH�g�B�k���|�M�p/��[�i����iC�L����S�
��-/ϼ�x���Y��~��c���g�̚��	���«W|A
R)ECQq�N:U��?t�O�]�n���I���q�-����U�.~}G��O��|��N���񱻎�����G��>R<s!�i}D%{��������5�9���~��4�K�Mn�n������3#�'8���HeNwL���AZ��Jd�\0��˜��\m��H��v:i6��z�g�<�]"���­�\��k��`��k|7S3�-�]��|�DӐ&��4i歫�v�^��k���K�B�c��S/U������o7�U�ð�b���2c,�)�*��u��M7�T�ƪ|:��*C���� ��7�g�}$��F����6Tx��"ky6!���mg�Jf��I��2e�#e1GYa"_!��NZ��?i�&�kt�{�\�TM=1�Va�V*D���(�E"�rݧ��4��bt�|(�K������b{��?���|��4��×A@*p��(��7N�п��YP�s �$�*s�`��Ku�JT.���l������B��R�2Q���@�>�VȂ���'�W�v�E�v�+;m�n�,�Z�nw�]A;�S6�C�y�����>x��������L��4�z#v�|Ub�+p����XxT��gg��������!Xj��?皠�Z*X(�q����i��Y*bK#����N�3g�F�tR�%�P�G��G{+�)�S��,��~�m��1D�i�G����#:Z�{��E:�h��m��6�+�M��2�$-�����;4}ơiX�;-�8�)�Z��N{��Ð}NGWü�����A���>������C�~'�r�d
v�߉P��;3�a����%�^��<
#	�"S��D�c
�\g��m��Jv���d�v�u���TH&\m�n��Qn�v�-�im���x��r�^�%�gX��ƽ�q��kR���(��C�=����<#���~w��(��Y ��~G��`}�@�R0/��yϑ*T�T��f_!�D�<�"%9��۹����s�M���SnSb3�h�V�5��q�㶍�ҽ�������=v�p8
�T�N���y��r�i=�qw7�LD�F�r�'���Z�iSAU��.P���ʪ�v��S2�̰�Cd1�`.;���o'�e~�Z����M�����S���\�r<��� ��̓�U_��^!S�/�@=+��KX�D�y)�K����� ����l����#��Ok���W]���}�,Nma��6�LJ�X0EcK��ah�>{�8j��YŪ�[�B�-��������^޿�v(h`]	��|Ήy�@�3���ߝd�Zf|ꯨE�wG����I��Y@�)�
�L�"�S�8V��L���%˺x��&��x�Y���V��:�`�mG0��TH-��e7Ӷ۔K��LC������pvIj��tE��NW$b���m?��?���� i1����s|�X�P��,9����I~hM�,oe[�]Y1�S���c�����9�qo��ٻy9�W!DY���Q#Ҽw�˫��w!�.}9E���������o9�np���ϸwST��_�dx����k2x�n�Ak9��Y�x�g�s�]���f�#�VΙ�HA�{�_I�s��#�s��������Zm�AZJ���B�!���S�]ʩ{���c9��3*���8�� -���@9TmΥ?n�Ƴq+ڠ�H���p��ńq��d���	�ȗ�`�I���gy�/ٟ�z�g���V��ة���$�W��GpKz���0���}���}��6���    G��d�v��
6v�w�?��V�M:�-l���Y8p���O�8�=EY�2ff�\���`W7��ַ�uX�c:M5-.��t�ɄcuE�-]���mC-c8v]O�iU��@(���{���t���+7�]�"d���9d~�7H���݊����f��Α���fE��wjZ�r&Q��+�m�Ŵ�i!�'�+cjIZ�-js�6;u��J��Ђ���:��δ���m��m:`�6�*M�0�
�\��#�d�:�y!�lZ���o�K��bhm�9	�4߈���j?�Y�d�������vX��1�}q�П+&��!݇�Ck�g��8B�� �_���ykOAtL�d��-�<p˸&��<�z�'N�<�$d���%@��I����N���$���8��|6Vk��V��ƛ�꧑}�e��|7�Z��F+g�����c�5�'�4%��/]��*�E}�BlT�t~5�W?���Qzq�-�����/w�9J�����~�=�ǉ�}~w�Q��#�X�ߨ�Y��^�(��(����,s����z��`p�h�y��W������8��6�.���>�]���B�%#BbO�i���ڶD�D#"�5}ib�#�����I2��|t��%��o���~v���)���뻳SvYT�]'������=W0x��Uy���Zfby� ��ϒھt�D���1[w NM1��Xf��c;F��r.s]޵X[Hq!h�;%�n����#�W#r{8S������C��!\G��j�fr�4���hE��{|��#��d(9`-h��k���
5-�B�+iI����G�\!�"�(k+�sƂ�-?f�r1=��d�.�]�e�D_m���Ѷ-�خ��%#ұ4�;��^PYY�<R6З��kl��qJ��:_�axp����b0D6�ч��}_a�;�s�3d�U��V�<�I�U�O��*l��P�J�����z^8�	�8OCoʘ��n N�[��#
�A�ao�Z���V�M����n���� `xe�_<ˊdU���.�/xT��I� ��X���4؄k�,�i��^����xJWW{9H+y_�\��Ҽb^w��ZY��[��t���Ls��4��^z5g;�7���Q��ӫo���WoP�ϼB�vǭ�f{�uvihE+���"~DW���4���zS���^���_��~���a>v�/(���H�-.�j	F��z��~�q�q���Ɇ7��^������A�;�藱��)N��I��rZBhv|��8l�2'u���Ik���V�8%K&	���x��$K�d&w�b���.��B��>�ީW�I�SA<d�+��W�|�5�a+��Ei�nwj�c=M�l6��46���CE��>�l������P��T8^A�s��'+0�L�]��Il����^��m�.��ݭ�}}wX`웰���X��7�<��^����X3FUO]�4��Z��83X/>M�����o�t�m+CY����u��m+%�UF)�nSچ�]HMN�L���|��ǝM-]���bs����H-��/��*>LZ��Iv����!LzW�d�|�G��G�Ke_�q����X��� ���
Zs����*d�oI&��� ЋG~6W+@#ؔ�ce	��D�$	�3��s��m��ҡ6.m�LV��BcI�p!�m���K��ڶ�y��4������~���j��W+*��o�p���L�]b��������^�99	</yw�HD�ٌf��`V����	���s&1	�S�s���L(�q1�m`X����Z+U󶺫�h��m%�����&mF:�#����p�v���k\؀<�xD:�x
uɸ����i�h�{G<�1�P �s�:)x�(3Xf|��gX/B�QΦp���a8/�!�t�
>,��ſg8�E�7���2��2e[ƅ{M�$��J��8ƕԪl���}�[s�l�Jʊ �Ԯ�x�
���K�{Nf��LךP�]G�hm�IV�C�⠤�\�GUE���W��_�~uS!O���|��a
����0<|�����Ap_ ���0�݁������J��!"y2�;�TȌb⣮\�q
]����M���c�h��Y0FDh����<P:�a��n�c):\�9"x p�?|j�V6]��>�te够�N�K)Og��~�a��[�7�b��&��dj�cIr5��8^m�7]yy��t�3vTT�;IAV���`s=�c�t��r����z���:�opT���|��������,���j�ӯ��!�f�$Kd���A�Ȳ���3x���C(g]��nӱ��,[�Yp	B��W�
G�&��0& Z1m�w��v��n�F�\Y���� ٥UC���rڷ�s�����GE��m�c���6�zE����{�S��у�i���Hu�YaF�D(�B�Bх�CCm�R��xi-�捪��+K�"-i[ڵy[p���*WY\X���M�K�˟�4R�!���ѯP@�-Z�8X��cU���l��G��`J�������A*K+���U�+���A�U/� ֚��;����L +�]��Z�l9i�
0'	�L[z�����p�x��|9V���h���k���D�jO�Y}.�5��^����X�D��w1T�G��(�9�����士�sd������'��k�$�:OAt���E�c=��^�J�\�c<!)��a%yA�Ye"<�H>H�B�$��������(z�}oO-)�.�v���(�$\)�*KЮ�f�\w�m��9Ա/����m��ѿx��'��	�K��	���Ǜx)c*�M��H�|"��#��|����|.ի<�`'�%�Q	|2�ʆҏ? K��I�6Z=$���G��p�--t��7�~�+H���О��[缿A_x�xa��B���!���1�c�����b�z��D*C}%�)����Zl�=��/}�z#�"VbѨ�te�s+8��H��.�Q�� `�>#�=V�(�}q)��j�=�=9_�Q��sͱ�1<$�X=����5RX������3�r�A�#i�;-
\��1��G�R����2]�F}h^WL颞c��7r
���ݱ�ZmKٝ�-q-�����.�ZC�'��V�k|�XUb�	�I�3��zN ���������z����0�d�i���^?�Y���TÐ�	YG��"�zl89ɂ5��%���/+�3������0U`�u��[�lF:�PN6�i+ׁ�J�m8���l�q������4����S<�a:r�_&�6^ku��[�nO�S�����ɚ�3���lt�˼Av��'Y���i*z
�`%C=/��B�/������ۡ���{|����O��]�1>���v
'N8ܾ;Il��/��`W�k�u#�)8E`g©"Y2��-(ܝ�d�1d8!ȱ��3���M��'d�t�kuh�v])T6��l���|�pq��zBaJ+�0�3$���t��d�:,�Yk���=S�^`Y�y�͖���j5މ	9\E�X��S哂ˤr�P�(g2A�e�IX�g�M�9����{����jX��z�5�r���]�^ڍ{��}�y�dSV���`�{��"#����6	F|�!���Eى�pb+Y[J��>�M��ґ��]a����ln�m����i����ڽ0M$��T��LW���g;I{�;��a�z�fʎ2
H�� ����kts�g!��DR�b'�6G�z5�/&���P��@��B���A)�BK96��*�Z�;�F�%l�����'�R�݁X�۱��ew��!��8�LU�3�����L�R�r����RӗP�K)>��Q�楙�b\����K}�*O�3�����L�` �}��r�h�#<������������O�X�*��U����,|�v'3��䧂R��=���GRI��Al)n��5���5¸Ci5���2�����_���;�_2�oL3p�V�=Z�p�_^Jz6�_?�vLA>��a�`��X�Cy��=��zt��p��ݙ))r�ơ~�*�QQ0K�?��B69�� D7V!����    ��W���+�d'�1 �U�n�іC$�Z]��k���ᝂ��78�R%�s'��P�Sg��Yh���xS��"U ��Q-�V��xGU Yo���*�:�� \X�}�o��6�o��:�H�2���`�N�v�n�p��Z�]��m� ߍ:��Q&���(�%9c���kԿ��?�%�b�B����QY������^�9���.ŵ�����ƍ~ԨQ�$!�+��� �Ü$�,��q�B �R\QcoKq�]��	�Ș-,ǡ�a�t!ŵ��c8e�kۂð���aXEv$�����Gq��!�c�A솂����{l�� -�� B�y���H�`�{-bouD)�̬�Y��\���BeL���ÐM�R%u�a\�Q�ŵLG��qG2����1����R�ݶ�`�ZJ0��IvZ�G��@>Iz)Uu���u�t� iA���	�^a�.3���^}�P�
LY���� ^t� @մ�[�Ԛ�g!͐I�C���I% �C3M�\��7!��ژ�m�kn�6�n����R�9��Rȕѷ��P׊�Յ�b��7�  o�!���J1{ߋ�I�Z�I�~�f���^��9dC����~w�T�5�R�!��m�z�M�Rl�f+���`�햹N��Ui�朣�`Sj�C�)�c:ݮ���H�t��׎��L��Fv�b�Zu��N���\\������?G��Nx��m�+��D��1o���;��1\���~P���)�F���(VE������ѱ�v�S���M}p��17�mK�!nSpj�!�;����m�V��ז�����(e.�:[��Ճ�i�P���9�>�p���	)o���4�������ƒ'�2L�1�|}E��D��$*���_b�Jo �S�d1��BX�}��S-��mǾq3�@�ِ�w�r������T��6s�b��D}�O9�*D�'aa�[�jw�r�q+H��d�Oc�E��m���p���H�&"l*�D+��|�5��#8T"��l
���|�꒼�'�]+O�V4^�����A�g�.���d1����>ۙ��g/m҉�9T�D#m��`'����+�B��	���8���-Z�:G�� �FK�a� |B�f�H�`2l_��;�O[v���Ik�;�OV�p�#���l `w�L����pR��Sns֌_�U����S�����ֻ��^z�Ph�����1���/�>��W_�3��9.�_��R/V���L���u�~0x��d��p���
ݿO�h�-��b�.�t�j�iAކ_�Rж�Y���-dw��;�1��L#Ƹ��۞�:��{i����I��0w|�[�y���N)�Lȼw��(��7N� ͻcر���U�5��s���Kd�	�5�F�L),Q�;Vb�k,��
Ǔ��6w;ҢMmOWvں��Xе�Sv�PN��$�`�sW�����QA�`�G䥒/Y~��@����Ar9�lEB�z>����M����}VG�V�Ɠɼ��JFcv�΋�PP��	����x�F�fZ:�h0����(c��C����v�j�'(�b��L��IF�,H�D���*9M��ܗW����uõ���U�IrH]
q>ݭ�o����y���y�/�]���Zܠn0�C��� �h0w�K��qX�9&:�W�I=�c:YCz�:���`YC�$Ej���%�H2e�j��7���%]�����p�wH�U�c��n�[T;\��n�����-Z:?�c2A~��R��������V�ck6'�]����M�f�T8��\�8�Pᠪ�}��}
�Oe4/�iTq��0uI�������9E��a|;�}NFw�|�(��#d$N��#^������oЧ��
^�P�b���)��$��<N����K,�/uX��mq�E�ڲ�D�b���i���Y?!l-]�]�i�hǹ��g��@���;X!6j]�W�񺕯����� ͸Y�جX��m���(9m�JV~�V���(mL�I�߯�g��8�n��o�����1��#ļ��e�j( �����{�n�ςT���
Vq�;Gi�\\pd"{�?��H�h�G&D��(4Kd"	��Z�#��Xq�l��4�.��׀���hB�p��!��c]X��Y����aW �q�C~�4�0��vj��Hx���d�ʐi��SISELU **|6�g����!�*���9O��ݲQ�O{7�2,�a��$��xy?���í�xX��ۜp�!MO��*����q�j�,n�L��H���>��2C�i$�E��B%������]�XY[v�*�k���8mc��e��,V�+�^35Eq�<�%
��wFnJ}��&dŭ`�NZ+��&�T&�b���5����r�f�a6����>�7�z�$^5��K���3��%(Y]�{q	��J�պe[̥i"5��"^L�gY,�ƷV$��g�O��>�����q(���8�$̥���}�[��*i���u�]m&���l�W:��8N�$��"��E�ؕTBH5C����;���~"֥"������a��x8���4�4�2�{k�����R�|Z����4e��e���	���Q.�z���Q��\���9�ff�Ƌ�	�����/^��ڪWyR��~FMT N����M��o���X�[�������o>C]p�����S]Bv�H�˪D�X���m+����2�����/$�'u�QN�R��-ǬZR7�#�Zj�3��8'��,���fJk̰z��
�?;�?>�)J�S\��2
����awW!�V��\7������n�ih3��0�o��Ǿ���\ls. ��8�T�F��`��M��f՗d�<c/��G�>�a4���t��f��CkQ���H�[�ڬ��x�-�=1I>���>��9�(c�,w���=Iq�	�iD���x ������b��=ڵV�z՚L�V�|�/���,�d�%�˵L�EF>ZĈZ�3<i���1���h�p�$?���hЎG�o�� �o�-��c�?St֣�g���Fl��늓M2FV6�au��<<�GO��yaj��hA�JtY ��0u�珕��=�=�q�N��&�]G	�eJw�%��8Rq���c EoĘ��ڣ�YH�����4j��l%<��ԋuN��b�#��$y8�|J�Rt��_P���AU�ա-Ʊ�]N?td�"8ݥ�ƭ��r�1�/�ل�)�V�-�	آ��W����Yd��O����q)B9��˥�Q�/�/d\~�	:��d�6ڟ�^g��Nvs��{���B���}V����^����d:� �>������ky���q?A�đc�/�y8 =D��0����wՍޛ��H�b�"�oxX�����
��3�$4�^nb��J�F�</X)X��þ��u�C,�m���+bC�Me�A��:]J/���'saS��3�����"��O[��Z~���f<u.Պӕ����`z��8	���˒��|����R��®D���l��5��8��;v>��#�D��+
>B�s|��q�o�w��C���EOd�/��z߉M��&Ssd\	�Í83R^0Jk/�Q<���_�W�����.wm�*�0�`:�H׵�Z]ᴑ���˶m��Պ�N6��E����|��Np���~|��c�����ǡY��]����O��-���|�y#M~A����_,���1�q.� 1TF���ù�R�� B"�Z��7��.�+��M�?&��5(�d�nKc���k;6�)k�~��t|F�K��7�u����O^>B������������{HY������}ov��ؐ!���r���6�;��� �>�{��U��9�v>�yK�	!q����1D�ǒ�6��)׬5�̌����qx����?���	��`	^��9P����u��U�S�4A�GC�┼��eTg�v�᧝�/� �˹o��4�*�ю�]�f��7��%+���߇-�jV�zAnXo;��a�	��Er3Ϭ�5^�s!�%�l�ӢPV�?�    (�� �^z
�8�D���v�Ϟ]c3����A��͖?���b	`�T��\o�5�J9�7����)�v>��OW��^j$���J%O�6�Z��}a$����t�P�?���@���S'Y�}LVi<t1��Yj��4�a��H��G�>/���ě�앱P��	%!���dg��_�0���~ړ���s���G{Wכ�ۣ��c�tHF������&/����T��E�K�P��t|��K�'�V>DF;�EX�r�HԺЂ8��z�i���2̻��H+‍l�cq�UP��u�_��(]�6��/1��W�j�I�\�c=�߸_�!*��G�WE�Y�r��A��d	ߢ��<����q�u!�foem*;iG�A�LIەr�iHʈg<�?������0f�ܺ`���ٖK��C�^p����Ԁ�:����{�K�O?*���N��L;�e���B��L�qb���n��dVa��A����ؼ���c��=_�4�ӹ�pPƓݬ3���S6�.���,�t,�t5�5+N���co��}��G��G�i]Z���ݾ�lf���h���%��_��X�i8g�mn-����҄��]v�����V8ߠ��oĝ]�;�->����WM�h,�b�NV[���x���~��T�7"/r���,���]2[u�E�u��+|�3K���-�3M�y��+G�����ؼ��>��[����zzI[f�/�짤��7����Yh�ղ�"+/7�"e&X��ꏹ~Sg��"��бR�T�|)[��Ww���ǆ�ƅ�v>��[?�_q��Q��ޏ�Fq�
��p)�R�q\����3c�W��_����Б��̢�'��;���q)���i�|_��tB����;��v=C��Lu�Ў��у��ڢ]�iD���W������;6�7����cz��^6���Ὢc͈"x *f�ֻ'^�dVv�q�t��5&�|���k6�Y���<��c���z�m[�!��=�I[b[�5Ș�β,;��� ��|¹���VnVI<�-�=5�kP�n^�Y�����T�LӬ��
�{��I8�;�b��9&qy����K�ŋU�&��&�غYڨeb�~�Uuت�>@��*���,:�=�d-�-].�1�cA1�v�r�Lq�!j��y��$�#D�A��X���u�ȉ�=͂�x9]t�٢J�;� ��b��Q(���0"=��6���|ޱ"�!a�Yl
�E59#`�t��љ��K�����p��>C���S�ix?��Wÿ��L*��L_B����k�wK,y���p��	�^��x&&V�L����_M�d+��!�=Y��5�a>�h��n��jnШ�E9WGJJx���u�x{�H*k�zgz�B���z���oj�+T��k��i�⼪�c��'1�Qp7�۳B�]��0sCI�8�C����y��s���|k���}yZW�5N,�	�P#����v����4GHp�g����KIϧ�w���l(��w�j��p�-zW������s�����I���;,S���k;��P( ���'F�t����P!"x�_��*C�:�Q씋�s�Co�*��i���'�La���`�c��$�\�A�fއ�LM
�-C��������D��N8���6�<�/W�X.'�9�]%�q�w<=;U��	׼�d3����S�<Y�P� N�^��S��qg��&\���i9��T��t����H�]��;��T׼�mX�è��^�s�,8(9� LϽ���o9�G�~��ď!ʃˑ�m����_ݲ��<�
����es*�4D���Ӱ�ͤxݩII���$`�(Qk+C�v;��dS&t��f̢O��t6E��n�T	�2�EZ�M��e[�Q���r�U���g�-]��:�c�h�Bqz�p �wV�S�Y/q ų���N���82�����b�o׼��$kǦR����N��%��T�N�Ow�M	%��by:�ɱ�t��/Vl�(=�D��q:������D,yBU7�y����Bz
_\�Zu��`+"���z�
W&I��Z��ʎ��q��>kw�#���%���6���~ًu��m��N��V]%K�M��ج#�#)۲���1�V��ݼ�B���qN��f�gcÀV������,PP�gZc򹘿.���P�r`�2�s~0���Y&����=�5=����M����J�����Kk����l'/#	_��X�[��j��n��lJ�]<��֧��n7����5�����:�8ۮ�ql"	[^*�,�x��r��aY.��ڄyS|����rb�e4���&ё�������\�$F��'a҉�N�"j�t���GcH=4�l���:���JR��)I��kg������$����u_�� ����������X����7Ct��;�^~K���o���ɑ�0Fr@��!��.�82�j_���qt�E�� 2�*a�B�a]��tI>��4�>/�MR�FW�4��#��c�����e�\X*UA����0�2�2v!��Xy�![�1JyeJI�K��[�t0ʇ�?�q�67�8A������ z���6#�{�Q>J#6��]��s0b�Ð��"���k��EP��%�[H!���R���j
�[���Z�I�pE>-`�
���h�mҏ:1Xm�������`���%�y���B����&L��V���,1��\��T��:M�aP�����b��J������z��^	�D!���g[���PE+��\H���%U�Ԟē�/=��|uu���1�f���t�S��vݮP�v$�2��9{-��N������/�eΦ"6�8l!�7W=�j�}e���J��E��!��7.lA8P��}8H�Fi?�S6,�&����õT�%�\�;n5���)��<,+�j�V�\�N��4\0�#���e\	ǟ�l0ʶ�O�(�u�M� �Az��+����T��i���U�yȋig���$���x;#|��26�9���%�4��Ϳ���n��*�O�ȋ*��m�󒇝�b��ID��L�B1�dY�S��if֋�*�X���#'�]�O�Mb�S�!�}�o�M6���$m�f�m�p��9j!�W �����g㢓��'[A�q1Obc��P��bCL��`���e�7�r�¹U��PG�,���;?d�N�<E��SZv�LFǡN�h/f�6��d�˧��X��ꓪ���Z-t�oR;|���/�8������:i8��j��f�-�JζVZy�Iȴ�&��t3������A(�y�g�q�^ړ��= �$�e�i���%j�G۪A�WS�'�lE�y*��n���l~ʂ`�9����lZ'?P⨬ď�&V !Q{M�1܎U���kQ4������]oz���p������wo7��~
I��(���C�7%Fg�"A���?hJ&e�b�:�lLQo`�&T(��C�Y����T�q�zaHK��юNB�=p�L���8��n6@�-af���±� ��8�WߝdCvG{���a�-Ƣ�5ʐ_}SYk~�#߮�^�^}��N�)�!�xyC&MJ(��<j�2��ʕ�ZQc|�aWd�և������Wr��JvɱL�0n|߁��q�
a4$о��Zy�i��YG�I����{5�)?}��Yg7N��S����*���2�bf$�J�o�_/ȧd񹜮�E��_���y�g�rExh�1���hV)"�*�2��P��9��g(JT�%PΑ�bE�M�#�0: �3� x�.A���e�s����)�Q�m�ѡ���nW9��ہ�>�6U$����l#D�����M2b�*V�:|��%E_CO�Я���Y�:�5
�M�tmL6)�Eh-�%�bIgP����*��h;{z��0��u�U=�y��V)�Ȩ���4��j�c)��of1�{���0��H%0�-�:�Ho�C
r���
m�}8�[x<�RVp���3e���Z��,6�+!�R1vزɖ)$)s��b#Dc�e������F��t=�Y���}Ήk���K��ZJ.�ei�(�3�+>�$�uP�S�\��-d8����;��o7���#j%���뽟��    �y?��n����w�{�hq�`�[�E�÷̄�{�0�˔Eq�x�DU�A�C����\hÅF������P�w�΅�B1uL`�˔/������!�}�ֵ�5���X=��V�X^�5�o;����o��EǛY�$�@ִ��qK��)���6�w��l\t�d/E��d�z��p*C��kR���O�,�1�f�>�i^�y�n5&y��T&��	�����$y��]�L��a����	�C+�Bm �����~Y��A�VTI\/E�����?�/=K��9�@�
����Җ����ǅo���LZ�%��"�B��� Whh����R�O!��ފ᠟c�ڿ�f�,�w=�"I����y�����P���_�Dt�Vd��<Rd�x�mÉO��@Yb�n�(�cX�T��l�+KO��^��N�+q�0��1��`�WP0z�QT��>�lΨ���ƺଽ�\������� |5�P�#�wO��C�O;q�u䮌�:ج��V
F�l̹��Q~`�I6�i�8��z.D����\ƛ��p�4���tUਘu���#N�i�5�KK"�-g�$ˣ�5�:��&�6zJfu��4ͫ=�f�fׄ��5rݿ\,8��r�b�b�b:Uj��y9I "*� ����l�[Dy�ƌ*z��q����M"+�v���G���c�٧�%ˬ�"��DG�n�z2ߦ��S�"�o��7��mX���Y�:V�N+��Y�Ls���$O7��R�r�D�<�N�㕥X ��l���D���Ӗ�u�_}��O�����JŴ����}�Ɲ�z���j���<�2�kj��ni��,��3߆�o4/����gѴ�XUSJ�-O'קQ���I��iVa��4Z�*�܎d9�܆Ay�<������>����p�5��_W���J���0���*�i*��b51�o�����Pm�;v����UN�_�9��������퀡���*�� {�_�^��{�p��:�x��
������G ����|�,�T���$6�ߢ��\�f�D�1l<K5I�9 $+����f!�<�MI���5z�]�3�;��2���B*�*Amϖ�2b�Ҧ�����3LY�Z� 8;`�F�Pl�״�G��a {��qop��q�l8�D����;��x�g	�p��h��^��-��c�GUz���V��d��Q���dɡzƥ���e��@�k�.Χ�qԕo�tUWC�̠z�T���
f�u/��:)%|�j󫴮���������k<��,tH�v�a2������*ʚ��A���hЃC�n����!6�[d�<��{�����熤���ÿ�Ap��*CE��O'q��� �^TGEʢ2Gv��	�Q��y�ͭ���eہaާaY^W���T���ʶ]J�J)��}ץ��X��8N���)o�z��JA.�9���0�f7�������[^Y�\���q��z�c׬���Ƚ��ۇFTH��\g���e���&є/�@F+�a�:'�\��JA��)t�j�G���PGy�>:�R
�1���X³m�e>yW*[��U:�g�6@ͪ8����f�W�������^o��W����d����A������~ڻ�8M��.Nq!{�yC��*$��)]�h	�L��{)�e���!~!^�j�n�Q�=;���i�;r,N-��y�U�B�?��.7ڢ�'�eC�|j&���u��6�t�^��[���.Z�M���R�MN�r��$�q���3��%$Y�߼�3gY}�J��<�L!iE��Uɮ߸�����s�IG���3��@�Us�t��="���ݤ��7�N����b�+���Ig(�E�Y�A�:���E�醓���P��%=��'OF�FX�[����D��"��
ǁ]�QA=��/Y�8x�دi�
R�;�t���:�L�Yڙ��3�F�jͥL�zc�n��l7+8��O��&XM�m�wͿ�l�M���Jy���~B�?\!o�g���D�A�����H��tٙ�Ţ�`>"�<-Nu�g3d��I2�����2]O�i^���B{�Uc�:�3�tf8�9��Qg�FEg�Dg�q���|1��r��f[��e%q��B�Fм�s=�vE�c6����y���=�ȩ�1��`���~H��K������r��eq� >訠��ÕސOՋ4_Q�o>��Spf5f=?pfhy)Z�_�����Cop�����Q�1�D����{�ݏ��}��w'�r6 (��pR���쒯��&�(���|���
���b�&qe�ϋc(Zqf�Kҕ�9L�gƏt��T�*
X��C|iP��T0�G��؏���������q���<X��܈�\oss�{@�[/�V�܆)Ԓ���T�w{bt�Wi���C)�<`賫'��幕T���Z��K��(��d*+R25	�� N�j�gQ6��􈙡��R�t�Kf��>�|%Mύ㛫�GDsCYCn�����}D{����L���}?�ӛ��K3�l(*�?�7X2WB���V��hiI�͇�l�Z/3��"��UՆ�MTF�'OT�e�c�,�q-�	c���X��H�'�ۚ�\��y�tR%(�,�e�>;�t�p��}�=��r{�+�� |�z͆�w�0�*�~=�һ7j�!�ZL��pZ�I���0E,T�����3l'aYy�a�l`�������U��u'ǩfRy�sT�+|��k�����p�y��h�d���fb&�e�A,wj]i���
�&�+�������i&
������6�l�&�4��8��� k��<�������8�%��2����w��:{*X9�n�d8���<'z(�'g�(9Չ���`����bc4&Y0E2g	�����ɫ��|����f�&H�"�63W:y�ϣ���,�0�g�_}�n�}��2�����-���Qe����pp͡�x�����{��M;)�W;y�"��y�)�f˃�u����%�"0PBS��ژ��E�9�HX�"�筦����Ό�])��,�(��~IwF);��=J��tKz���0�#���	Uh Q�FW�P�~�F9NU{O���KIf�5D�룴��A!���&t�G�5��Al�-��t��ؤ,-����t���.D���R.����Ҹ�/Gz��][نZp�b��QZ��+J�g��]��uE�qE�(%���zY�Q*H�ګ�R���/��
���˗����Ip�黽�^jK�W�G�����:��.\C����T�IL�	F	�DmX�C�'R��h�s�4@�,Z����'7e���a��Rہ<���/$�6��w���ڮ��@q�6��p���菈AZ�C2y:�(�֝<'�I�OK�Y�I4��m,+M'kR�7u�ͪv��D}��y��`F}VL���^�����o�0�#Hw�{E�oܢ�� �t'��=�=ٿ��p2Zb��P� co�E.��C�+Af.���,QM"�����U[��ߗ��.6���[���r����!_w]"���w-<Hđ�DKʵgK��y?�����V�;��	�`U�2M���#���_%_wA���vߓI�j���VP".�ΖHŝk(A�qhD����u?�Tjv	mQ�������G�:���e���Z�ԚL{L�Lٵ��=Fi��t�^�+J�8����{�{i�^��QW��q= )r\��^/����N��x���ELbAW��D��	�Z�<-�1&L7
7���C~���ks�_����Z�P_�8דN^��N�E��d5#:��:I�6�X&����%j�ף��W{nX�nTw7��2����k��]0:�ǓuZ��,c��)��`��M�i[]s�f����N����Լ���ݟI7��I��*�3m�L뫩�T�I9^�H�HeZʱ���-?l�B>�����4���ט�`��R4���n����f�+�6�x�.�O?����6�:Z��#}~�b�ȗ��H߫[�K����n�K��)��)v�4L�w��-n?��g�r-K ��|���z-T�@����?��L.�$��rČ)���h>�^���    ClF�H눢������.�ڞ'�r�ki�sȷ�.��R���m�%sI�W�-}H߅(��ȨR�����h`o�WT�t�"n-�p��
l�K�C�W7@U�JCĳ�W<	Q�r�C��4���^C��j�E�TI�ڦk��V�gk�JKic�Jw�#i�K�el˳|�r�A������KۣTֈ��5J�~�wm�M�MU��^:��ȵ�Jp���#��������!F�I c��Th�FU�^G��+)�JT2�h ���)6F[��}<nlɺ�,J}~�C��]͔�l�(.�X�*Wx悵J`�>���j W��z����_ɺ�H������:)�ٴ!����j.TL��q�	�,����:�w�#�~���s��I����*�Z'��01D*Nʅ�eN�k�0FHQ���BЯ6��jӪ=�L���Q���-�"т��v���e�;]�,&��	�ٖ뻆W=2v^a�l><?U�����v�0��G���e(��K{p"�Á��wO���#<#����-T�D��HE����.��_R�>Y��D�dCE05�3�a"����\����Y@j� ��Hu�9�6D%��V���XV�e.��P�{�i��7�Fw�2BN:2�NWX\ͲN�n���M��|��n=M;q�[��$�;��J�����[\��Ś�z�*a�Ή��rd�})���������C~o�GHͿ2�C�{G�����A�5�x�TT��K%�������zʤ.'�Mp��G��ҝ\��jIZ���(ڪ~��޵k|T����ОG8Ӣk�c����v-b��c�)륶��(��� ����IG��'�����
B���_�$�}֣��/�poC���p�J�Q��F���� ��� �	��}�β�j�H�(�4@�PX�����S�l��]��cQJ��*!}�tWX�ڮ+a�W����ڬh��m���Vy'J�8�B�hpM���a�z�^>�1L�)����e�_��}O���do���"K�34 *q��i�ZZ���ݭ	,�����'���"\
],�>�S��1�)f9q�	>���8H>�ϛ#�k�w����}kcD�mksG�����l��� �A��b�ط������d��>��I����t ��$j�,�A�H\����D�h�]58a}8�۶6���MZ�BY����Q��|Ml�\Aa�����~6���U�����5y����|���߼q�)$����Pk���!rs��n�p�{�q����?>�#�I���~�S��,T�c�ل�$���$n��W�Z�6m�I�`7{j������8��d;���C%Tq
Em���]K��q.�j���0���E�U�H�lD�~z����!�w�y勓:��A�����?�x���{����K��I�����^x>������������1���Q�!���������zF�J�h�t�ܫ�t`��Ƶ���I�� �+!©k�&[��I��U�����F�仹��r��d�A:["���������'����^��~��+���p3r����GG�F�@��r���ͅJ���JmXŌ��R@ٕ�zU�"���f�C�X�+��ľ*�-��Y����P�Cx��m�YX��\��Ͻ����q5������Ԙ��|�P©?4y�f#{�*0��\��M��
�s��m�Fi��>Gn���R<�b��A���_�a�}8/?�-���)Sj��γW����M�R^7��;���7+TH$K�}@)��I�\4N�e�e�o�عh����_2�+���%�e��:��xq����2���w(3�T�l���A?�qm~�����[(��_�=��#7�����~��R��j������H��x4����9�@����8�<�XO�u�¸����)͡L�*�����}dq�W*�ޱ2CsƉO�]	���2�r[+�#�.�íԱ�����b�� ��V�����|�N�~�������Q��h?����͡!�A${�l۠Zv�����0v���*C21a$+!�1��%�ĉp�"��E�b�b���:���zL(}��L��v�k+̈́�g��n{P)k��X�5�I�ɍ���U�����C?���h{-F���(�:�ื7����y?�q=��´�{C9|���A�
��hbR<�Yd%I:�b�N+�+�D*��@��
��z�/S7B*�v�c�>�j�%�mFm�m����R����d;=���}���K)���wGq?�~�C���y�e��L��"�#��ۣ_A?�>�JT�؝�c��D?��+�	MIi�.�M�?W��=��R�"c�u��޷�ڬ˙M�cD?�6Dt���q��mnCZJ�]�Z�悋v�@Ԃ�'U*�Q��B�8N��մ�;��f��qN7�(���M�r���\�'��.Z��jH}�0���"� \���I￥���im���Gl��\���f�s���v��n���!�L���(�Xd�z�D��c���ᦄ������	+�s7����U��<�����)��PeS[�#���߶- M
JG��])]�[LY�j�p�bR5Z�����gI�ts�����oy���~Ͽ�ye��j� �fp����T�2�&I��-�kx�D�	��)�����9�@���1B� �G]3�n�N���t��#���F8>��6a��k"]ˢ.q�Km�/�nKy*rf��=�KQ�C!5W͝�t�b��=�N��4��Q�3(}�:��a������ޣ��W�y���K�����X�
h,��U�#���+٬S���N����vI��\��h�̳�,)���	���J�ekU�6/��e+u�e��*�<�S�[���3�r���fIg�~��m�+Vl�PF�r6[��|-h�]��S�$q�۬���K��4'�?�����|���}�
R�z5�%$C(?Qd�f�%G������+Z�U�{����gv���J��< ���V�(l�12^�X(�ԋ��yX��TJQ��\N	��ƉR�#&ѧ?���3j`7q<���lg)(	WJ|e	�{�`���;��ƾ���sM����7/��g�����$
N�А��~���=(N���Ǿ�=��[(V����*�	�|�o��)��Ȇ$AC�����@%�� a^��fe����}�w&R�  ����b�e�[����&TK�`�����+p-���-����1����2Tѻ�|v�`�;J���A�Ї0�{[�=7��A�*���2���-9��|��CI�J;7+9�L5&	�
tɄ
��kx_��n^��~������-jA2ku%#�p�G\��R�a�(m_~�=�4u�F��0v)�٬H������둊��9�)���z���|�?^)�Ӹ L8ʋ�I�zp��e�.��#X�7TL�ăp� ����p���j���Tsɺ���˳��l�	|GZ�x��]ߵl%��{��LI0���ђʖ�t����A7����N�﷝�$B�-��*+����dI�r5.5���'�I
k�l�&u�^/wм�sE�vu �E꬝~*"��_R��)����Ӷ*�����/�`B��z�&�8';��v�dZ`���R����:����3ٔ�!I��`��g���r?JF�x^?U��m�u����Faod�������D�@VU)yCg�lI5[�>BK�WR���9I#�BF��8Q
� �s��ZQ���	4P/@�x�3��QBK%��9���Ǵ�����T5�>y������ځT������K���.��c�)�V��-�h��r`��x�XHIXo�t5�?a�G[JY��ی����[=0���9ݯ�0�V=@Oא[-6��E�������ɔ��v�My`�tDE�HR�ŧ8ޥQ�I�g�p1��<����?;pܺT��Ӝ���3^��ΦD �Z'��9��]���,�[e��i�d��ּ���4�'k��?�ᨮjL3�E#�q�	�򩓆cx��Rf��eh�9�Zqh��&!�R|�L����s�*�d��3����3
�l�Ԯ��5����Y*����VF�V�;��s��W�&�?�'i�VQ�|�|^=��I��g��/x-���E    rv�H-WEY�����>��&ɧ����OW��-��~�V�\TbAm���x�C��(��y D4�-�_�����o�2�6�;��5�B�T�E��d^R~*>�6+=Y�d����PZ��<]s�F;����5��
��ϻ<|�����ׁ�;��q�T7G�C���2-��!�<�pic;�'q��fF3���R��N�K���.Wכ�U>�>��="{O�4��ｇ7����W�q�Ұ� 9Ӏ�������3N�\	x�	\�^�寊�Q�Ն��V��P�j�b�~�TN��/I�7�C�^R�TTg��~<[1vsK��?G���>{&Ր'�<j�g��k�w���U?���)
��'���ċWc�t��(� �`� �x���$6}&eeA,P��p�2[�*$J��%B���j/�껒���ӵ�E�ܱ|Ǘ�4=&�@����J�|���{���ho�����O���[���#�v�|I�i����|���*h�yf�E����·��6���6X��G3U!�	��~u(Y���D����M�csK~mrG��Q.U=y����#��"�3�Gt�^?��z��}?��5�W #��φPj\?�\Ai��~8W
�����*E�I�z�j�2��l���4�з��0,���$aH����VPu����ϱ��=y��{6'�*[ڂ�b��i��r����u/�>���M�5#�_X�|j4��z�}7n�����L��w?�6���{:�B@���Sm�!�k�*%o��9EE��:P�b��z8pA��D��J)k�G'�.�0;8��uN�E��eׇăh�Jd�:>'>�U��E����>�	��"z��A.�y~s��׼��>	�k5���յ�娆s��s������R�~��W,+n����ɒ��r��p�GQ�&י�p� g�m�)�kʸ.��+����¶��������Fwl��+�d���8������3y���f�ý�o��X�J�q���7��&��yo3 �ڃ����ҏgc��xڗ	Μ�[��5�YC8N�)"�`+Ų&�J�O��$z�Õ�[O��^��BM�g1�;ǶS����S�O;� G��]�q��঵�]�	��!�/�?W�N��� ��!�$�CIs���0�+tߎ�p��{�-���_UҜ%D5j���8Tǐ@���=�fZs���P�D�W�JX/@�_�9�N|1E�hI~�q�iH��(#����ᖮ/��X%:��6S>p��6�����j�ax��J�1��#��L�m��Ε�F�ɩ�BSK��ql������Fs������h9m��#p�ƍ�� C|��������K�w��h�~et{Ǡ����Me�<���{��w����C�$R� �(
���}�gX��RH��;v�w(_eJ���(��@�ؔ�z�'�z:��;��8�k+*8W�u��	��Rýh�����ӻ�p�ӽ`Ҵx��a�ՠ2UA��n�7��4��~�Z��k2��tO���))��M�js�j��?<j�`�� ����M���l���e�$���M娂X��
�#{8�ͯ�p+��wb�?����3�'�0z}��T�@.exS�j�|âB��Z�)� �PТ�|֪������+�o[�v]�X��%��2V�����K+�rz~�Ϭ����$kzWw����S{�\?���7�U���������l4�c8���>^�ET\�TU&�q��yG	Y�O,6�1Z~�
��%|S%�n��yX�"赭���Zy2�JX.�Q�ȼ��Xl�W�q`��<�a6�	�R�F^o7�:�
�R���5��ה�ΔJ�����E��ZH2���$�i�Fx�v�)ӧ���!�p�Ŏ[*-Y9��\fb��j3�>��H5�����V�h^��)�F=)�>3����jBO�ߒ�;��\}�*�z:�c��Fx�<��n�p̠��+8D�&*Q�Շ��(��xE��|���"<�+�	(��s,(T�H��6���nN9g�y��u�k_	�g6��P|I,��m).�>r�T�XGۮ��� �L�-%�C1�O�m�m���w����@���������L�K��F�%|�oi���ʯh�!�8��	���;CSX�0UG�d�z@K��6'��V}j���l۵�5A��\�F�LR��&�O\a]�*�^�ٳFޙ��!{:�c���D`��_*9����JN��N��}���z�ol�<�Pl�Rg�4z��Y�D��֊�(�qR��C�>�׋Y�QF
R�p��Z���s�>>���<Ȅ�Ȟq�> 9ԉ�R�i�#�s!Q���l炳6�١K�k��C��E⵻iz'�얠_Lp[M>����뽟�T�i��O�����7��*�y H��pj�"q6���a����,Q��s�*DT⩏hʹ�+^	hC�����G$����"؞�{(�mqC}nڻ��r-��Z�r����B2����Jx�B��d<8�|����ӡ��ak���il��2�M��h���%���e��谀׉����p��<�Lm8��s!`�S(���Sy�7J��l̡��>s�R�P�x�E|�`Z"��K��V�iV�*�ak;��|%N��޾�5�RL*5	��������{?��C���!��4=_[��6����,�S���N�p������8d��V2�xߡ���ͧ���֌��,�..PQ����X��X]Ot)��9�P�^5U�8Ǿ�S��k��ۢ���p(o�o���U�T�`=:��s��x/�<�V��S(-t�Bs�WW��AdJ��a�Zd�W(=�K��
�����k��ߧ�Ֆ�}�#���<۸�bZѮ+l��߫0�\�a���U�[hG�]J�T�f�ݔ�R6ed����%&�e�8����s���n����~^؋���Y��X]��������,�oᚪ��o�4����isT�	��F]H.�a�@��f]�l����F�2q���h�1����?��y�=����X�
�CR\�^��3���	�������^
A�K�NI���I�n����;�\�
�_хt$w��)���
�F�jClW(�2�0=��Y��N��_JzƢp�FW������j�y��`�ݸ�,p�0r#2�e}���ZtV
8���Do	Ӣ�,��P����2����j���q�D�|�x�c>�FS���r7S��m�q [�Ƃ���sK{�����@Td�lq:L�%7W����w����n��cp��-�!�]a�V|�8�`+��պ�_O�'�����y��yZ�Jy?Ԡ��� �[��A��!��������� "�T�`�ۄ����*ƴe]PFh��n����^WX��5�\��'��������u�mi#�P�����s����G�؛	Q�d��O�S��n��-!���{>ʯ?��7Z�!Pj���EQ ���8CH[��D�By�I
��(��i��L����o��j׶�ˏ,��=F�.��8��k�(�t��O���ʹF���͔��Ι6��$2o?��7�9�8�:�S���P��g��`�}8~���j(��L��x@kL�(��r��I�6g� �RDag�-�F�MuT��������L}-u�c�
ms-�!P9Q���S)m���S6��0�ʹ�Y����?�
	���aUA�*3����_�}�����@q\Q��s�)�o�L��O�)�C&�UROs�`*��5���!����Y���,�z�fJ�㻊�c���5Z��˸�' �}�+u\⸾p���nSԠ�4�|2������+oss�J[g`?}D��fp�;Y�y���G���+��re���KV�1 a>��6s�LOHD�B�Be%X,�;�UùA;�d,��� �sԒ� P�;�q�]۳}r�$�c_ g��ȯ�PЬܪ���&�++���t�I�\��N\���ʚ�����,�XE�΢qL��>m���h�.�!H�=Vͤ�lF<��(�P���ɾP�\e����v��z=˹��3�'I�!�`�����Z�8b3�H�aڼ�3mG��h�=$��    �0X���<��7�7�e{���Ȫ�֥��V!�_�?S��)����_�G{�;���9�����>�7̯��䔽�(�q#rsu�p3�xj=�\O���b���%�X.�'^ŁPbtU�Twt	cFՆV�C�����Nn�B:R��Aa+�4��R��r,�XR��եؑ���]�,�e�� ����.!3m$�ZL�Un�qD�u���	)72�$�Ӻخ��x�h�ܚ�x�!�0;HY����s�@�.�l�|����Y��F��b��\�������\�%-���'�x��.5�$�$N1h��G6��$�|�
o���z�=���U��뇯�_r�47=槣��R���2:^��L�h���j�x%����� �?�CՉ��l]U�ȳB�<�	���u^��G�Ӷ˘F��#�*�}�=ja�i��Pw
��\QOP�C��1Ms�*L����ӑ{���G�Ssc�D�~��i�w���{W�㢚�L"0zC���W���OQL#$~�ֵ	���:5s�1-�����(���DS�8�8�|υ���c|��y踚"ָ=���y��H0:]��a6��ɶ>��v��Drn3�h��B�[2�����i���j�`��ڏ�y�gPV]tc��bVY��Ѯ4��X��\3H/�*����W�����`�ܥ�7����Ы�7���^�-�.���j�4���ϖpAZ�&I�*�pg���d�|^-��Jx|����K,�[G�g��Uz�%��[Y��w5�cݮ���^�Nu��`�W���'��;\ngx��0K�d�4�=��qR�\��)r��̟�����y��G_�Kt�Z�A��j5�^^t����	r�L�P� ���?O�?�ȧ߿�9���@��ԡ���ZN���Z�.�m���庒w��]u�$��Å�B:iP$�^*�l�����,;O�}�i�+�I�:.�+)�E*��̨�Z��Q��i^��
P��PKAUX�R�!�\���˗���&)"D�d[�br���2IBKH� wgS*�D@�]IE0a�� [2���A���V<F���ŵ~�:ԴЗ��$�ª�4�&����g4���S�O��
���nU���h�K�$���QQ��5�h=>�y��,����o�c��A�Y���K.&Ag̂N��>e�N��B��b�8d�
�m�6ѧmRl��(͒���lSgC&�[�͋>�!k��*�?�q\�iC��s�T3,��KO��N���r7���h�N��%+��i��r�5l�e\,��+�����N��=�Lec'��k%���|�gp�0���.M͞Ѹa.v�|)���i��AB�hJ&�i�7	�,h��R|J���Ƅ�)�ệ��Fq��R}��BZۼ�o���wc9�'\j�,����MƝd��r�]'���)�q�$��F��,��o��|�X��C�Iм泯�Y
��R�C��Z7��-�R��]����pᏓ���y�I�Ы� Me�����<H�_�ʳ���,I0Շ3������1�u+8$K�p�`��S��[���őC�YT���)��*rz+3��N��l:�C�f]�b&�8���R���M����R� �м�3y�#��HC#wO*F!�l>,��/�p0���-�����;�����w�� �ٗx�N��|�h� ��Y�PK�Q���0R�;�!��są�k,m�GjPȧR��[5��wJ�1�AR���h>Zcy���q��TWڴ˺~�]hu|�W����F2�1�|R�ý-���Ēu��l���r�%k�-�a�%���|�z�ea������bK�KH����� ���![�i��ΖB#2gN�i�v)o�އ����}&���ý.�|_X]��4�O�Zz�E=�C��N�����,9������էɮ�XGO�x�	�z�3cm�����A��b��3�&��va頳����'�nPYi^�Y�͛[��b�遼7���Ƽl��7k�G��Nu���
btLb�C���3�zhV����O�]�a���:�Td���@�W�����ąqJ�eA�*�B��]_�n�5��୪6���bqt�]rL�,����\�:�t���b��f=�|���,�Η�$�i)P�<P��R ~T�.��VL!-��I��x�W~�Km�w!ݹ�>�q0�Q��٦����yoЏo�8�H}2ʒ\��^�d�Dk��]R�Jf3\��D��PB���)�I�v^�|_7����u�y�I\_1_9B�Ʀ�6S�M�]ݵ��F�g�8��KAΖ���q�:�����%(Z|3@�q<Gq���e��g��q�x�z����I���T���L��͖|�,�h�&ђ�{�j-�k�B	*�HZiq�}'H|\B}u,L)��C����(d���0i[p����ݴAe�
S��)��(�a>���
J($!L#�;l������磤ǆ�ʁF�_+�������0�	��J�x)����<��l$OH�X� Zr�{k��Oo�a|J���	���^W�M�md�+��ZH�8N2&�M�{TdxjΦ�0r�7�W�}{?�C��N�
\��6Ct9A�xv�0A�ha
;iM1'_�	#��e�.Y��{�r�b��trq��S ֌M9{k���d�v�&J�Ȼ\{���0]�-!�c��=��mK������������"�w��x�y�Kx|��1��i�fylJ>۔j'�O*5mn��1j\虒�>E��&���*��B���C޻�~@Ք��у�I?�:�(Jnӌ�oe�}�!ϡ��T��KV��oi�p�L1�Yead*\8�t"�_DB��ʹ-
���V�;��,�;�Sk�t)|���C��k%|����Dt����9�/y��f���ji~ ����5�����0%B�_7��s?�T�JC�����B���E��T)P�Q<W��l���<J�m|�~�-\Ot��q��z��y�U����w�������S6��G�:��3�T5E�1��L�Y�U�Hdh��&R�,��٧o�����_��Q�U%�'I�fb��$���3-�On������t����ةe:gi���f�-&bCf<\?��Ϳ�Zּ�s[�c,�ʖ��/n+zI��J�A�Oo�����G�W�HfO_��(�ݟy���-����w���&|�+�������c-V��g�S E_�!���:��# :���d���c3Wk�uDG҃"����a�=�}&����g]��ZgQ�êm��v(}���z�7h�����1�,��/�y�F��f��[��\���N�
^�6��\����F�R^���󑋇����TѼ���g�̡����Ͽǐ��ÁM���'ԏ�y0��c�Æ�S�$��e����.tG�{���6�7 �I�}�(��>Z���G.6�����c)��F��u�.����)���b�m��H��5�~S4aU���t�_��u6������;���:SO�q4���G�~��ּ�����e��$�R�3r�����%2��ͫ#�����d��z3r��t��7n~@��x G�BU��h�A6���&������޶m(�������xU��/��&�ܥk3t�e���H��׏��5JDYA�P,Alʌ�C����]ں �>b��e]K���0]�T������i�1aW ONq��'#6r���*�026��zIG㫡s��>m4��m�)go@��:�~���#k���>�u���R-S|w=�����n�g��~���pM���:�f�~;���V�����D�2�:I� �P7`�8.��ZX�w2T|_��0���=I��Z��%c ��Պu�Mu=��:�Qw(�Bd5h5�^z�uXa)+<h�先��$���YW�*�p�:C�W�#0���0��#,��mjjj�w��w�+H�<�r?�-��i8`��
��"�JukJ�%b)�&��>^|x�ɺ���ʷ ���X��+/|��>�j@pP�>�W�
WD�B��
�=]q�J7�����.2�$����������')k�?Ѥ$P�}�`����^�E���   �I�AOP������Eo�;��F��V�YTV��.�3�1[��F^�o6�$�9%,=E��"K�MZsc���
�� ��:E��in��*Cgs]f��8Z͉�*	|g�:�R��A
ʳD.�Q,y��ֲ�ij��h7$Z9���6�� |�/	|�R؅��[a%��D'��(Ҁo<�М�����d�{⁜�C��J�U6�Ȇ��9C��'(>A�Q9�D� ('\�O�D��ʖ�E��ά�s4j�hw��c�]u��#�����ߐf,KKQb�0U�EϠ��j�9̡`��6
Q��:l�|��m<=��bh�ѕ��6U+�%Iq(�
�6VR�� F!��y�Se��=A���ɛ�m<}gp�dOU�ǒ��h����E,�֎w�ܭ�eO�/	�X���2����|zdP��y�5�� ��c��(�ug�jiCaty־�U���򝲡�{+ݱ�?�|[g�T�k?T����o�<����{�IH���z�u��n�3_~�.�e��n�����K�l�ug[�sw����&�؎'C��g&S��0>�j��X���"��oP���3_��T�Iy�S�aU�+[�$H�1)�Ҋ�����(�J������ġxV�^��d1���aBXkq�+ۓ�V)��2�su�&��#��PK���pT���Лl����C�0�ɏ����F��M�Mr�?���c�ᄟc�O�OR��z<�ƃ���q �Û��Z��nIs//ߕ�+�Ż�u��v��:�����/������/*���<�N�>�uҡh ������r�Za      �      x��k��ʑ%���+�}�%���5i��5jIֳ{�z%��2��D>�b��o� �"� �ؾ�m�,�K^y��{��p���D?ш�MD7��B��,�E/Q����Sy:�Ey*N�5?n��Kz:~*ڲ(�O�;��V�:����?���n�-b=�o��)?�?�����w�;�������_������Z>���e�I�Oy�59o�d���I��Tr�'�ȧObIM�6�[F��D�t��mJf��L?IY��ӧ�����l����-f1X2_��T����'>�6���.
�@R���RJ�\��h6���f���@�(IOe{��mw<�"�w�9>�m���G1O��X�@,d��i�:1_���|r�'uu�)V�C��\�L���M�u_o��=���>�Ͳ�Y��{uݵ���IY���Ħ(����4�q�R�,�/�ɒ�*�n���N���-����%z�_7]�%����%:$�Y��9��$'��u�.\"�K4�4,�����4y��u^%�k�$E]L>v�$�G]�Tv�̛&c��Z�LŽ����y���v��)�]{��u�/�K�+N�K�d>�l�(����su����`�f����OV������6�>�:c��/�) L&� &S`a��B��ך�c��6E^��k<Q���/ƥ|��_����Kc?f�?W�S�.I]Ҭ�ˬ;�3�O+����^[�mU��e_�D<I���Q%�t��?�_C�NR��C�v�U}�Tͱޤ��.k�[�����bb�Gy۪���w���6b�5+6�YP�����;���k ��I�0E`؊9��$ f��X ���l�����rS0 3 7x���� f n
|� ����0AH 3@� �a�P �Sba� �Saaj S�c���o�Nl��]aÜn���O����7����+��(?<:�֛{w�6���a�,�nE�o)��b)�}���?Xz��(U�8�aQ�}ז�Bb��r���Y���9���6&q8�9��'���9�L���x���)|v$�̛R?�M2V�Ǉ>�����zjrA���,+��S���e�� gEUյATUy��P$�*�o���=pU6�R��Jޙ�)r���v{��̕��.9neu��N�>�T����YKz�����M�Q�p�����rsx\~,R�ГF`��[hѯ��3��K�t1�ԙ�������C���J���m{�nn�U��*8����\ӫ�x�^������Z���Ya�&^�x�~�.i�:��X�4B�w�����Lv���<��Bu�t)�b�#˟y���V/���qs��٦~�j�.>��Ӥ���~��1e��E�]D���������;�������\#
ֈN�7�:�=�͛W��a�3�m�H��������&�{/[1�O'�������5I~;^US��C�.r�#�i^ܐ����߆M�-X�XΎ��٣r��*�r�s�E�Uqj͗Ғ�W\��a_����:ۜ��m�=v�.�%R�C\\���X�Yy>�yr[�O/�,Oޖ���|?�`�@�+�6os���YU�����}���N��r�\��v�t�ڦ��v�ȵ���T]�o��4��>_�V3z�e����;�O�._/�hT�(̲��lW2�-k��{r�:u<���S�ؔe�g���N�aW��<��ۑ���,�j��i�7�|�p}��k�Z��l�V�[�ٷ���מ^�����Xo��O�^�S��p�fme�[v=�KC�$g,�W��+�Aev���o�%���/��eH>��n�]����/�s�L��i%?7�8_v2)���'�<��ix��fy�{�YWu�)2��#=��m���2��y�������X%�ߡ�4�>�Y�Fvr��ݕ��u{�r�P7�I4��E�������ۜ��sJ"ANs�����!N�}:��N�tƀU8��ܢG��ӱ�G�GA]����	��g���]�g��	"b��M=����.O����&�:噸-���N�}���<��;�~f�۸ݓl :-`ɟ�����g��ëm�FD�����^�EJ�}��b$��ҳM�n��?��|zǨ=�f����t6?��?��^��M���C��.��*�r�RE.I����&�^���⛏npZPK�F�̎c�6l	0%R׭��y-��^C��bq��(��}C�.&i͏{qS�}�:L�v2⛤�m�jg5�$H�=���^7}5�q��jXJh�"Z�t'�u�s�,q��N��mͲ˪՘��ER���|���M��#����#K��l��Re�>F�����ct�Ur#yZ|Wn��y��|z'�ap������� ���-��=+���1��M$A���x8�"?��͢��eGs_�(?7ɽ�*�.���'/�eD��̚��y����t��~]�>�Y���a?�,#�>�5�w���5r_�)�����8vyӜ��w�����VϷCCVf�p.��BoW0F8+2�B�����_���>��5/��ڔ��y����мʊ�P�.W��~��T>�h.��V���\߈>S�u��Uܙ��=����t��5b�50%��d�%P�k[�H��9Eyj�!�<� �MO<=�j�>w�h����N�:ܛ�F�r��Ӆ)�Gܣ�W���r����=�������Ɂ�ٲ�y��#�7�z؀u)m+g?���'vIyu8W�����6kRM���d+ȇjO������qS����2t*{�k���[s-'�����~1�����-c�=�^�����߉�7����-��/�/גi@E>{]�������P=g���3ѡ��l@�6��_7��屹d��|;�[����r��-�盠J6z�M��ԇ��<�L��޿?l�៩�,����ϵ���(���ΦXV����͏��U�PN��7,zĉJQ����2E�NT���Ε)��┸��)N���O���OdI�9L3G�y��w�Sgn}�S�11��E�>xZ�3����ϊ�M��8��}��*5ozl2�p�������ɝ�?;4U6A�4G�����Y�3��Ø)��K�2\��v��l�]�۶�)����(�;�~�il���� ��H�ԉ�&��h�1��&�~0���EU�+��-٩T\�'��
�Y�bG�T�5_:�o?s6j�|��$]�'��`863.%3�}h��\ղm�y��۶,K��*LU���΢�s�,��B������E��	qpH������M�a�N��'(2�[��SN���Od���)�!�I������h~�on�#N,?cg~"�X�P��}�b���g�fE�P��z�}�K^t��O�^��տ�y�v�l\[����Mq��6a���IZ��b_&�	�D{��E�e���3I຋,kM�/���٬���:H��ݴ��*.����V7,���fS\�����]&Y$�f�Zj½��Mr��PfK�a`���!��r�w"�FK3����߁6��!�)�d�Q��:���CrMڸk؝��Ioo�xE�7(����������%b�Q ��+P� ^�a��Q ��7��b'���հ��x!�"��X;!iz�T�u�V�x�^o�5:3�����>�,/FE�ד�VN��/�_�ݜ��o�MĬ��=������Ӿg˝У��{�	�9�ݟ��y�E��yzbwnD�:�7 �������u�d�BdY%:˪�!��
�e�dް�'2�:��a�#N�
0��a�#N$?	TUT~�h~BU%���O���A�����)(wZb��c�׬ӓ=x=�l�lק��z�[�lʮ�o�G���l�.�v_�|{K�����l��fa[5
#�"غ��%��YB�i�U�w�%����꫸?ŉ��kpB���*�;8��0�٫������1�������D�B����g8��!V�>{n�#N$?)sp�'A�6'wp�'A�6�pp��'R�18�?"�U�wpb���!��Tm�����H������D�6D2���j���H~2���O�jcpB�Z�y'RU�PM��k���	�d�9ϭ6��V=w���_���sG_ʓL:8�G���S98�G���3vp���#'�G�G����'��!���C8qp��':������8������wp    b���!���C8�GA�l���	��j��8�:��	��j��X~B�Z�~'�����?���䧀�hu��c��C�)f�Z��OA����������靟��^��F�(>ZZ��$��P�������;��.����k�95}�AR��X�]n����v�W!.�:�h�1�[k[��+&]���w�����[�$�~+�F��z�I��qb3
��3DF]�?� �a�#N$?'�7,zĉ���6�qj�>�Sf�eM�h��&�J��x��М���JuY��k�4�u�S�_����g�������іC��_I���qxb?@߯�dl߰�'�~c ����UdS��h��i"��O��hgD�2/ۢ���h����~��}�\�b�yM�v�%��ϗ<!"�t{�������# cp���)��-�b�ZM?���$�뺏͊t֨�a^d۔*ɟ�:���k�j�?o���yӝ;�T�ljV���I��1���ǩ\�G�~��R���Ǌִ
��}����z�Ҹ�m���J�u?~)^�8�������6_�=�wtI�M�ESn"o�$Q��q�͎��y�d�o�� B8b��&o��F�X� o�W,��+޾�X�V��"�}_��b�	o���hw�g񬕜B.?HQV��}3��wj��KM��;8���F�ȃL,�~SS�U,?��3?��}+��wj���g���O��X;8C��������OM N���O���c����}�p��A��@?w���n�6Z�>w��n�6ZE>w9{���|�Bg�lI��{��m�?p��|�۞�7���U����k���е�a>ǂ�dU򢫞3��z�����~������P�g��ߞ����V��ɴ����vÄ��3���y�8��n炗�-��֢��T��?�yΡ�T��
_|���,ҷ�W`c!A3��|aA��TT���O}��i�h��P��8�Ҧ�l糏tQ7����ks��E}�w�H�m�4,]H���oO����S��"���{̞"�K�'D<	td�`�	���4�ͳ~ Z��C?;x����ny����6�Z�����R��:��۽f�����nm�g杒�ˋ����`Ϧ�1�O���}�A�J�b_��Q�9P��}���1�x����*����v�Ttmƶc�£j���Af�l�m\�0j���~&���l�������c���c���>����NZ���u�k��c�n�׬���y�e>�V%m���J�d_�Ǜ�rOW4ٙ�.}G�6_,�h6��F$���C�f��?��ZEN6�L ��'�[���ϚI ��dsk�X3`��ln�"�hh��'�[��v
L���vV�7�5� L���z�؋Ú��v���&�
HS���q��~nJe�i}���}�,O�������|�H>���Q�7E���0�$��k���S��{�v�}q����mv�Gf�y�.K�|�2,<�`�<�����b��}K��\my��䢎G&��VKM����u?�$[/�j�8��s����lv(N���U��ێ�;T����3�6�kd(��*���k_��@���������y��\.�=��v��l�`��q-�����=�������>O�B���|��*v>����{>�hw���h|�g��$/A��wg��*.�'scް�'�����仳�h�O(%��l7Z��JI�;ۍV�%W���:����%/ߝ�F�Ȓ����7>���D�\qX��;O0Z���X����+s���m�U�{D�?�ݵm���',Y]-ſ�ܱ�	���m�b�j=ai��p�'�o(����:Z��� �N`�V��'����Ol�N���{׶�*�}���3?�w�8�r��n)�U��%���?}���wN���{׶�*������ؒjN݊��D_I��j���;�D�;�e��ۼ��7<o�V�F���.�9nu��8�y���V�m����'<ǭ�ۼ��Ox��-��V������?ŉ�H`�����6�����!�'���O�|k�Ul��Y��hV�l/r�n�Wuuh�)N{x���4�K��6��a�n����Q*E����ѽh�Eׇ��2S��S[WV�"����R��v,*[�^�`�pm��=E�g�퇞v���p=��69��a_��7q�p�� u����	!�H�f����R9����!��T�;8�[��!��T�;8�[��!��z��*��J¬N��'z@�H�h��G+��N�����bMs>=R;=�D��pp�>�3|�2�S:8��߶��T��D�Nyp�O�2|�2�S;8C��:��3?���� ���v�����S��F��d��D�N�G�S����������G���cpB����w�18�?�ߍ��/����?=t����0�'���K��w�`>J�$�G�K����䧄����/}28�?��5��(}�����|��H�V�����O��w�`>JK$�G�K��^B����%\��#���/���?�_z����	����{��pN����3��kpB����%\��#���/����*?X���
�#���/����*?Z���#��G�X~B�{`�`;0����/�gx=������=��q'�G���V����?�_z�|�q1�G���V��� �DL�tp�'z`:���3?���l_�����s�>�g��6E]R�[�M}�ƎQ�X!��3$�uN�u'��zHˈ��暖�fa�7G�)�m Q%U�?�U��<�����b[�L�gF^��-�����3-����Kfw���7��v}H��Q����x��ޏꦾ�~�<��rӵw[�pb�z���T�"g�5U�ʶ`���!4h�8@��E�8�.�-e�����j�޶�h�>�lZi��Ej�ZfC���S�������s�B�4�\�K��N�:ZF��C��7���M���V��F;8C8��#gg��5qp�p6h1X��2�=��*���98C�-k\���h$��_�S<�-��� E����R98M�`=��Ll����N�©�ާ�P7���"����4*]�� ����*n���<oX��O1g~b�1���Eo8�q����yâG�X~Jg~b�1���E�8�����wQ�`[�&"�|��V��$��.J�"�I�?�]�6ZE�@�(�X��K�����'����靟)B����O��!�tp��':�$
�R��Abg~��O��!���?i���Ot�I	� ���K�Rg~��O
�Q����/E
�Q����/E
�Q����/E
�Q����/E
�Q����/E
�Q��{)BP�|_��"�ɠ?�})b���'�������*���#ߗ"��K�A��R�h�O�|_��b�	���K�U,?�?�})b�����d#�!�OE���USpUQ��\�~���g~Ter��Mz?���6��4���vgv��N��h{>g�Ѱ���(><�E���- y,���Y��8�"��h�zZe�����.�gmI_\������\�����nk�,����h^���ml��`��6F�@9K�3B�������5�U��:|�/���b��\�����
�wp�<�]G�:�3�����W)�";�ͮ#;���F6tvٱ�'����ȎE�8���]G1
q�����:�c�NldC�C�t��b�)�!����IgבC���b�	���9Z�O�|w��b�	���U$?�G�;��V��T����˞3U��T����;ZE�SA�c�h�O�|w��b�	������9L�O�|�_�b�	������U,?�?��~u���'�G�ۯ��e$?c���W��V�����3 ?��=iL����t�1sp��'�2��������'�s��~��f�	M�!����J�����S��"�0q��4��c)����暥��S.�27�[5v����i��9�"gA�p��e���\�|^������u�Fۮlʋ��SS�e�-vmAW-Ƅb���8Ny�JP����P���8�t��b�I��    ���a���sK͖�BIQ^(~̳������~�5�%e����?����T��}NK��տv���|�TeZn�/�]��}Kڸ�k}�uN�q�$]�|���y��Ύ��Z��K8�'	�Du��'�}^��幝Y^�ݠ5�E�"��hua�z�����mDU�n�y�^��۲u!p&��Z�����>_�����f�7v�=�5(����hI�t���Uv��J:�ms̓r�+�k��)�oi�'�[k��jר,%���V��]1���&�o2q�2��>�D��G6�JI���Ż�Gx�n���|9��v��D�1R�"���jWW�K].�/BaC���؋<ϖ.���$�J� /L�:��y�!y���duj�.�}��#�ᵄl���kszl�cջ���Ļ����P�J$����bKW��,�몶[N]�ivCs�Y�"շ�p1�܃~��mR#p��BY�~�9����i�͚bsl�^i�vW��t�߶�Ȣ�.����o�j�z�<,M��Ra���h�RxJ�K�X���PT�?Õ�[��͗�6ۼ~9څ�;q�7�u;�w}��;O[��;(��L�k�\���W��DD�+L�,�s̱��6��x�Ic���f��z�6y��%��u�����d���o��EE]�����@�vĸ�򑧋c�٢�ým��"�ɢ�_�պ:�m`�ﯿ1;��?Ws5�����m.���&V|���q˺�r��.���na�G�7�ۧ�����l�����u�A&�{e�h�Y���Kg��
�N���3Df{����G��m�N,?��3?�w:�����w:���䧆���w:~�{��j�I]}���H~j�I]}����,
,��ϏV���gb�J���[�l��_��}��xͦ�r6i+Y��C璒#�T��'i~�޺r�V;����1�a�Tq�N�O'M�l,��h&�y	�b�&؟���fI�y�y����e���.ɹ��>͒StdZZs �G˖o�p��mA�c_��Þ���L���N���D��؏V�
�"�]�G��^ ���~��-k�&�sD��*�AU�i�!�)��J�|y�\��:��m�rg_��v�T}V����u��m�OE���8~���S�K�tq��8��5ߛ���L]Ҧ)�_!����.k��/ũ�T��Ҫd"t.H~����J�f��B�9�6�������+�^H��͊�E7�l3����]%��GA��|����������G]���v����d��c�܊�LW��$�3dKH;4�Э�v_��d�?���lא�]렎���k��o�eѿc���ǬD�w�)'"��<�ʧ�i�#3��7��i*TU~X~%�ܬ��LaQ'6w]ϔ����n����.��f�I*�����.Tu���5��h߱����U�O�e�H�?�L�4[ꊽ����Nj�VM���j�����Ź���r.^7��ߩ�BEѵU�8Twʳ"�^y��+^�١��OtP×.ܪA�����˾���mw�酯�/�y�n.׺ڼ^{a�������5>��r_������lv���UZW�$��5�U��։���E�8��(�w�}��bCQxW�����*��YpxW�����*����5�U,?�O�kF�X~£��5�Ul�����{`�h�O���֌V����X3ZE�S@�{`Mo]�,�G�֌V���� �DW0!����`B:8C���O �}��h��������~B;8C���OF��D��,���{C��!g2Ln��a�N�z2�ӷ�>ZEv���{âG�X���𭫏Vq�{�f�*������U�>Mzh�a�#N�>1�����G���.�~���*��'b
���/�V����!������vp��'z_�H�oX�[�qp����"�9�Ӿa�#N$?9�G�{����O�V�p�)Nl׈C����;8�����w���*�����t6Z���#ߝ���Ng���w���*���#ߝ�F�H~
�|w:�"�)�?���l����*�?���l���'�G�;��V�����w���*�����t6XE�
�|w:�b�	���Ng�U,?�?���l��䧄��w���*�N ����t6ZE�SB���h�O	���Ng�U,?�?���l�����L~âG�X~B���h�O�|w:�b�	���Ng�Ut���S�=�D�SE� �D�	Lu�7,zĉ䧢����	Lu�7,zĉ�'wp��'Z?R����H�H�G�D�e������|l�d�8�.��z����r����>z�/Y��v������No��K��a?��+��5�z>���qW&Uqh�jֆ+)�<�W��T���XI��L���u��6��f�H��7�HOgJ���Rt��ر��L"p��K��U�κ!��)O���m���Gn��vK��}P�CoDC��:�ރӑHT�yA�N��T�EҊ�7=#p�*��`��}|!X4i������5�"�-�S����*V~��L@�,7oZ���u�饤�=����x����VR�}٤���I^��mGz�nz����r?����������[Ǧh����M[��<�άځK��$W%�fd��s8���}j�6�Zl��mN��_�N�ڨ.���Sq��m~���<o�W{q�R���y*� k&Yq/м������ev��}��d/x��ޟ��?�J���r����^Lu�x:�b���һ�����[ u�[�<��wէ�I�2t*����͟��M�[dv��q2�?N���/�E�� ���e{>[��߉�7����-��/�/גi�(��(��̪Z���������6�ە���Fn�T��,�����|iK��y*�k�����|���Ul���[���W��B�i;Z��N�eãU�q�E �=WӼH�Ӣ��,��c�u�7�Uf���%�z^�]�:t�o^���t�k�S��֖m�۪�Moۮ2om޵�z�P�y��,�.�_��kn[ ,��y�~ˮ�Uz��yγ؁��F;��������C��gg]���X}||yl��/_7m��EV��$+�e�ؙ�?���E7���o�n>O��3���U���@8m���������\�<�ov���&�k�D�T�ݙ5�&������Κf���Y�����Pgmf��� �<��KsD^�&I��9�zs*�>���hHӝ��]�R�n���&������X��>��9��u��F��1�|�8ʄu�����nu������99�6�K�"ITU|k�K&�m~���Z0z�o�U]^f�U�ߌ_�ZIg�f�i�n�ݦ=L��hF����sI��e�ln�׾���@��(֧���ET�ŉo�b1��+��%s�T��<��8T 1h8���Q֛��o~siEu���!O�e'o]������f�C�V�44r��ϗ�>L�&%ŷ�Ӣ$�zޔ��9~�q�թw���9ݥ���� ���vU��鑢��*Y�.`�GZ�n�os/^|O���ol�͗�mĶ��o\ծ;�i[�cRӝ�ȣ�(�������Qz���fM���͘B괳�ݶ�[�-��?bz�9{ݤU�ovi�JO%�p�3}���(-D��xi*�[�۩y������d�خڇ��PUr�S�����~۾�����/|�xy��Y�feQn.�S�I�_�90;�]�g~>�7��kQ�b��mUc�9��u�o`}h����f�����4�Y��<���'�	��M�m�_0Ӌ	�k^54.���<����m�l����ۈ�`�1�[Q/�cN��4G;Jf�'�|�Uҭ��,���.ˇ�W��nb���R�2�����#f��%�w��+|����Z�7��?��]Y�[]�9=�,!����/���h�ֶ��-�e�:!����\����vR�j��~��t���#=�Nq* #���=���B��)�޳:$�W�T�Y	l#1��Y�h�O���Ol���3?��X%���^be���/����O��!�����(�G�/����O�V��?ŉ���(�G�U�wpb�	�Q Ն�/�2
�Q Ն�/�2
�Q�{��1�V_b}'����՗X����'��h�%�wp"�ɠ?Z}���8��X�    �h�%�wpb�	���K�������՗X����'�G�/��'�+�p�.����L�0C:sP��G�����nI�?�o"եHo$Jηh�PI�*�f-�O��$�A��F�;��B��{��h��r�}��"_V���!�U�^ơs���{���'���w���*���9���=Z��:gߝ�����C����h�O�}w��b�	����ߣU,?�?���{������G�;�V������=ZE�S@���h�O����߽U�^&�?���{���pp�'�F/������t:3�]i�hL���IV���ar���(�����vs:n�M��B��j^��1�ݫ{��F��.��0�,��*��>!�r�J�Ep�m�ᤣ���=<��*�3����=�Dv&�p�o1e����I��;.V��j�v&��qq���Sg�+E�d��	;���8Z��v&��qq��LV��3��U,?�i�G�X~�+Ҿ;.�V���W}w\�"��'�B���h����C��!=1AC��3�h�i�7}w��"'�(�<� R(��C(0��.��b�#��'���8rp���WqN����O��JJ���=#�R�h��Dh�_�9X���'e�V��{<;C&y�''spzߗ��\����}_b�brg�}	=�.� g��w_L.b���O��8vp��'z�]��!���Ԧa��wg��*�����yߝ�G����̊�"�\��@��.9VEgon��mp��Lҟ�^ޞ6�[v�|��Yz�/�l#y���Sv�I�7!���~Dç������Y�b�bg�f-.�_�&i~[�~���r���G�7���n��aOW���x�����_��J�f�e�f�f���_Q$��.��GV���S�։�	jg�����Z����7���[��it�n���Ս6mw�Ȣ���g�yȃ�n}(��fVI�����Զ��Ѷ�I~�w�Qr(]�[��46�qrʏ�8*v9]�C#u.�O����߆>�W��ba��0���6k{T��Fg�n�Z���-ͽ���p��TO��_��V�IN����*u	���VlA�r9��G�&���DC�kO�7QQ�v�����˦�|�6��>4���c���v��L_������؂fQɀ�{�_�x�Y����P�k�{ߗ���n~�����.Ikv帍oqv��J/�u�4���<�ָ�Y3k��!d�"K	f�L�:��c�����z߿Nk�;��g���!}�S��嚤��B[��.�V�N�伨o	{6��Hʋ���:��U`Ѭ��9o�})��y5kez�[q]}k�)E�M�#�M���d9/�G^s��ښe�ۢ�Q#��s��o��\N2+�u^2?)%��8N���+q�VqGa2+�u,zĉLyrx$�ݝz���8���ݩG�X~ �w���*��ྻ��V�)y�.R�x������T�;8�����:=���;8CHF�T7���:=J[X~J�����*�������T7�����yø�a�b��Y���a��v�*��&�ؾq��w>��N5�M�O_7m{�3�d��)�_��:��-Qq|YQ�;�h^<?T}�m�+�U�y�¹�V�#��Pd�<���88C�1�b߉x��E�8�b���k�"��"4_�0|�����Ȇ�;��� E6�9Eh(��)��vN���;��V������)�U?e����)�U?e����)�Ut1��E��B�V�ũ�h��X��*��[ây�c���K�',��=z��-��E��-�V�����<XE^�f$����-�VqϝD������*n_",�=ny��̈HN�2�>"f�d��|D$�������H�������0c C/��#"a�.@�^��GD]�=�|D$������h�Ox	��e��*��
^B�}Yw��䧂���e��*��$Q����;ZE�SA����h�O�|_��b�	���˺�UlgI��?�}Yw���'�?}�V���H�O�E�U�z�p�����"���6�U�����w�f��m�Gb���یV������������K�U,?a<�;�4X�6�#1��}�F�X~B�;�4ZE�SC�;�4ZE�SC�����p���������D�S3g ~�������n�G�pp��'�"LD�T�tE�V���V�;8C���Bkg~b�\���������'���3?�z��?
�w`�?��͉�߼�+{��(�w{�"����O]uS?��I%�)�kgz��|٤���f�O�g��aw:e�]�[�ϣ��ZǨ^u?{B;�u�=6�mf�^�Zy�_���Aۺ覷��w<T�f��	�k/bߊ��4����߂<^�}y�����_�s��CQ����~�5�Wk���|�ho8^������Ǯ����rٷa�r�û�\�K�m���l���.Uy<���}"Jul�`��y�DHB��jt��7�n�b�ۢsYؾ�uQti��n��zJ������+���t����7���.Չߪ��9�]H����~ߦŕd��9�n	����)���x݈��R9?rEy��w�8�x�������k��L��o+������3���[̝�m���)�D���,�k�p�E��>ݥ�]q;�yd�튭����[�ma>��RD���?%�L�Cu�z�=�0��n��`Ѭ�:��!�vY�t�����m��w�$�>u�յ>_�Iٝ��s�(������-�YTfP��Y���Jg�[��Y�$ϊ�+*���<���R*a������y�6��1����ƶ>��U�eqIo���Iˎ�$Yus�̼f]eE]ہ�kB~����xmC�YY|��уU�qW
p���ap����<���h)���{y����R����w�� g��OGK98C�{ܕ��G�V���ώ08z��-���G�V����(��'�����(��'�����(��'�����(��'�����(��'�����(��'�����(��'�����huy�;8��T��=ZE�SA�{p�h�O�|��b����������*������<Z���#߳�G�X~B�{V�`[.)�G�g%�V����?�=+y���g���YɣU$?c�|�J�b�%e���YɣU,?�?�=+y���'�G�g%�V���������*�\R�����<Z���#߳�G�X~B�{V�h�O���YɽUt����y��<ZE�SSg ~��%�f� �D�KJ��!��֏4�G��%����tp��'Z?�����h�H���D�G����9�\RE��3?�����?
��ge����}��J��]E3�8���N>�I�!���)���#����)�!�;ֿ�H����\��4�;h������X~jg=��?`C�����X��8�w�Рup�ؗ���0g�玭�P�� u?�@��]h��E�?
Pw�������������qb�����9XE�FN���"�I��3?�q� ���n���'e����m���D�uT88C��Q	p����X~*g~��:
�����`�O��ǟ�*:�d���?�H~2��ǟ�U$?�G����*����0�'��W1����V�������`�O����V�����ݯ����U�#�u��U,?�?�_�;XE�C��w���'���ݯ����U�#�u��U$?9�G��~�X~B��w���'�G��~�Ulݯ������b�	������*�������b�	����_k[���G��~�H~
����V�������"�)�?�_�k�b�~������`�O����V�������`�O������_%�?
P�;X��S;8�]��d���Otݯ�����h�H��w���d��D�G�;8C��I���O�~$�?
P�;X��S98C��I菂�G�~���������֓��M����7�y�}[����0?��۬K~�ފ�>ϛ�A_y}P7~ z74��l���R����uUU~����f���?��l�ED�ؚ��i3J*�&��w�+*ۊ�    ~���~Q�f�}�=��=�cvh�W]���ٍɒ/y=�y����[�n���Ab{�3�/\��AP>mi<t�[��}��f��u�ֶVMw��֯��/v��6�Eth�5�v�o�%=�춰����&,�ۣ�>��}�5��3�/��ok*XS��ܕ]TC��8�;�v�Q����u����)��d�K��u=��8U�Ԫk�0����o����΄��蒪�[���fW�������F��.el^�W�|�����]�*s�d�.�\��]�.M�YV�f%�.�:�y�c�v0u�c�K��̶��7yԺ�]��X������Ϊ>����̟����Q��[��}��\O������{Y�-��������d2�LWQv�����ލ_Z!>�M��xeK)k���\kۦ������.i�F�����ݮ)�;iv�#1aD}L�Q����٦���V�}�r�Ɵ�~"�<��m�?��go��&+�R������C�����:M%���ǜ0Z��i�K_u	bd�<���u]��P��b	�
3�>{�cHo�����tɍ��FK�y�����ȵ����l۞�m�o:r>�mxM,7y7�=����r�
��Y��%bߣ�hVx��n�s��|��&l+Y�gb�����޲ds��t���ʎ���N��!M����x�ԩY����2��YС!��qN?v�?yJ�.ݎ����b����;u�2�����]�%�˅����������3`g���q��������:O`a��TC�����z�琑�.c"��ݮ�ӝ��f+v�Yڵ:V�R�ٯ�Q(s|�b�݉*�$�8���wUn�����ݾ��=�]�;ˊFW�V��tNN�_���b�G�K�������{��{"�n�/,����'�U�?�>��ߋ����a��<��L�с�H�dw:��Nk^����ǖ�`�Rtͯ�1�E�/q$�?�<�/Fb�r�=	Wëaw��yF��h�#m�f��������N��iM�
$?���6E��ߒ~�ɯ*i�|4�3�/"�<�<��3J��>�}*B
.�Ϗ��j�ur�s��*V��]2�/+\�L�=QUůѓSn�B۬��g0��ذ�}<r㮍C��url~{8��o��6OX~�	\��Ku�������+���^��[���p�B?��N&��*��ϋ� ~V������\�#����7ZEJ�jvDTΕǏ�F�z/��_��O��>����6[H�����R��:��۽fO�O����0����]���_s�#>3�B����0'D�d�����gVqb2g��E�y�����ԙ#��:EWY�';R-���4)Z~NO�sZ�"S,e�vE�ܑ�:�����ǵ>����(�u��/:��T����#����!�U�8k��X�]^4k{I0����,����t,zĉ|��Eo8�e;����E�8�e;��ǢG�X~Jg~��}����g^�	�����&3�X����g��O����l�/�c��o��f��x�����ʷy;�Tl���9~�ff�<��f�Y'�T���k�n�ߛ]�m��~>���������j'R�"���u:��	��C���V��d~'��VX|[_�Z����T�mݱ<�Ho��k�����j'F��ճEu!�Yǵ�Y2j�R�>G�����)������:��!��hR
���:yD<����,Y�Cw�wrl�ӥ�ى��S!����Y8e�~�����e"F���5�������Zϫ�k5��v|tQ�!�Ϝ4�gx^4��S􉔎U�z��Nc��&=���E݊]I�X�"�;rK�9���|�������������ط����h�}5�˂��mi�V���f�˧{(���w���q���S����95��H�n���-�u�NF�C��˜�Y]�~����I����h��~���+#��ٰ�q���*��Tfi(:�Y��b���l����)�G��$��Z�kyޞj����z�+zlW�r��&z�Hl騾W��X�߼jV�Xm�)ݚ��K�zʽ�z:���t;e��u�������O��o���/�O�?��׿ҿ���/*��G�o_�ǟ���o_w�_���_��o_���?������a����>�c����g����?�R'۽�����ǫ���/������&���݉����j��������������c�og@53�.*��"r�?�S���ܡ6�o�&��ۢ4�h����a��	����P?b��I7�]QoN�Ғ���9w��5�wƏE#J�k�E���L��|�Cm3!��:�o�9�뗈G�WS8�9K4YZ�RG�e����}��\��yk���ׯ��<�M�&}A)���}���h��[C�������Æ;+(5��=�!�kH��6��/�h�[C�ڳ��jw�f�a��?�p�w�O����r�X�dq�_������5"_b�]]���T���b��^�1��5ْ��QE��9�[���l*���X�M�w}Qz۶7�o]S��Q�H��t^�k��ɒ��8��t}��7��ςMʧ�4�~#��1��˚�����ε%�E_�f���(�^����fZg��?�{3gu�'�H�5���8t�q[;4�>#��0U����Ů���r�q�\�?L��D���Ǒp]�_`�ȱo�t�;o��j]=Ó�niز�!��^�>�yTYW}D��o�c^g���w�0�7��&��5 �N��a�N��bpR�ӷ�2ZE�� ��"$�
)qO�?[P�[V��M�� ��d�F�9�o�0�Fū�+y�5���U�c�7b��qb<�d�ѹ>~{_�Z����׹b
ch��|����"����(��Zj�A3��}\0�(L��)��������c�7k��ӄQ>$:��GO��u/b�F���� ��荓7t��P����o���)i�#<���~��f9�A"��/�1J��>"���7ϩ7�3rRo�4|F&���C�ؾE6������J]$Uٚ�.��/����m��&I���c�SJ��Y�����+���u��ͯ�-:Z4$5B�&�v���P}���$��z�XՋO� Lˡ)�?҃[��v@6�J�����������2��-yD(��GD���=����q`�K��`^*'�s�@ٰ�Wޫ�[Y�����yP���Ś���)���d���u�\�#J�KDTFXg�>���e_-�_z�C�ޗ򭨉h��澻d�{�w{٦ѶK��EE��ѵ>��=�.��s��f��ٲ�h�ǲe�f�l�El�!����}��cf[����w3����l$�c�NlK�x6�ϱ�'R���s,zĉ�f#��q"�9��X�s�C\���q��`��O���Ot�x6�ϱ�'�����������[�U,?��3?�5G<rp��'�np̉�3?�w�c������*���98C�]^��?�7��A�
'�G�GB�'v$t̡?Z=��X~B�z$�;8����h�H�wpb�	����?�)l	[��?'��߰�'����oX����H�7,zĉ�礹���Dǟ�N�oX��O���Ot�9���E�8��T��Dǟ��1oX��O���Ot�)�?��V������?���SB�;��"�)�?��V�����w�9Z����0�'G��#���O�x~r4?�?�A����������SA$��S`���?A�)��T�� �X~*�D~J4?�?�A�)���Ȼ�=Z�>w������Ȼ�=Z�>���`_���J;8C��kǑ�3 ?�v��w]{���gL���׵c���O��sg~��1�G�u��*�������b��!���+Ʊ�3?�y��#��h�O98C��W���+�um�Q��"^����+�um�Q��"^����+�um�Q��"��k�?�=���3vpz�'��kk����O�׵u98C�� ��O�׵uD�!���?u��!���?u��!���?u$ � �'���:����Ɵ:��(@�I񺶎�?
R���#�ğ�kk�Q����umM�?
R���	    �Ga�O���	�Gtm�׵5��(��M�&�е)^���� �6��ښ@@צx][����kk�Q ]��umM�?
�kS���)�Gtm�׵5�(��M񺶦��๣umM�?
�kS����ppؗк������X][S���O���)�G!tm�׵5�� �D�ښE� �D�ښg~�����6��ښ1g~��;8C��Wd�����"�(��M�f�����"��(H^�kk�Q��"Z���� yE���9�GA�h][s菂�Ѻ����+2�����A�qb�)��������靟̃�͕�3?��'�� �'�ks���Ot�9�� -zĉ��?��':���g�=�D�sޟZ��O�ğ̃�-�?
2����(@��<���� �'�k�ğ̃�-�?
�um	�Q ]�yе%�Gtm�Aז�е�][B@�ftm	�Q ]�yе%�Gtm�Aז�е�][B@�ftm	�Q ]�yе%�G!tm�A�V��3�s���
���6�k+���/�um��!��ֵwp�'^�V��е�h�U8��3 ?�R� ����*vp��':���?
�k3�v98C��W���3?�yŘ:8C��W��?
�k{��c���Ot^1��(H^�k���+�u��� yE��C$��׵c菂�񺶆�(@^�{е���E�8����g�=�D�sޟZ��O���Ot�9�� -zĉ�tp��':���g�=���3vp��':���g�=�D�F��ТG�(~���?9Z�68�?
r��mpB ��h]����(@��Ѻ��	�Q����um���0�'R�68�?
�ks��mpB@��h]����(���Ѻ6��Gtm�ֵN����k��е9Z�68�?
�ks��mpB@��h]����(���Ѻ��	�Q]��um�S98<w��mpB��h]���� �V�6�"g~"umc�88��kS��е9Z�6���3 ?���1����յ�)g~"���G!tm�ֵ�)���Od^ј��!���+S����ȼ"��G!tm�ֵN���Ot^�A$��յN菂�����	�Q��"V�68�?
�W���'�GA�X]����(@^Q�um�s揠E�8���N��h]�F��ТG�H~��3@��p���yh�#N$?���E�8�����Dǟ��Т7���sޟZ��O���Ot�ɡ?

�6��(@�)<���� ��k�ğ�-�?

����(L��ֵ�Gtm�A��е�][@@�tm�Q ][xе�Gtm�A��е�][B@�tm	�Q ][xе%�Gtm�Aז��е�][rg��׵%�G!tm�Aז��`_���R98C��k�����x][B�tm98��k+���O�����3?�yE�Q][xеwp��':����3?�yE%�!���+*��B����bg~��
�� yE��C$��׵c菂��v�Q��"^׎�?
�W���1�G�҃�=�� -zĉ�tpz���k��3@�qb�;8C���3@�q"�9�� -zĉ��?��'����Т7���sޟZ��O���Ot���?
J����(@�)=���� ���kk�ğ҃���?
J��M"��ğX]�D�е%^�&�Gtm�׵I�Q ][�umA@זx]�D�е%^�&�Gtm�׵I�Q ][�umA@זx]�D�е%^�&������ڄg��ֵ	�(��-�6!��`_B�ڄpg~bumB��3 ?Ѻ6!��е%^�&D98��k;8��k��!���+
�Q][�umB��3?�yEB��3?�yEB��3?�yEB�?
�kK��M�pp��'6�H(�GA�h]�P菂�Ѻ6���+�umB�?
�WD�ڄA$��ֵ	��(@^Q�um2�� -zĉ��?��'����靟
�k�yh�Nt�9�� -zĉ�rp��':���g�=���S;8C���3@�q"�9�� -zĉ�'��(@���6���?^�&�� ���ڄC �Tx]�p�ğʃ�͡?
�um�Q ][yе9�Gtm�A��е�][@@�Vtm�Q ][yе�Gtm�A��е�][@@�Vtm�Q ][yе�G!tm�A���3�s��������k���`_��ڒ88C��kK���O��-�?
�k+���� ����R88��kK���Ot^QB�Vtm;8C��W�����輢��!���+*��B��ʃ����3?�yE�Q��"^�V��+�um�Q��"^�V��+�um�Q��"^�V��+�t�yh�#N$?���E�8����g�=�D�sޟZ���3@�qb���!���?���E�8�����Dǟ��ТG�X~���Dǟ1�G��؃���?
�tm�Q��3��kk�ğ�][C ��=����0�'Z���еc����(��{е5�Gt�؃���?
�k�tm�Q ];���4��(���umA@׎�6��?
�k�x]�F�еc��M#��B��1^צ�ppx�h]�F��еc��M#���/�um������4�� �D�ڔ B׎�6%����h]����O��M	sp��'6�H	�G!t��kS"�!���+R"�!���+R��!���+R�Q];��ڔhg~b�B$��ֵ)��(H^�kS
�Q��"Zצ�� yE��M)�GA�h]�R��5^צ��ТG�X~*�w~j��M���E�8�����Dǟ��ТG�H~��3@�q"�9�� -zĉ��?��':���g�=���S88C�2�ğ�kS�Q��S�umʠ?
j��M�G�O�׵)��(@���6����?��6��е5^צ�� ����ڔC@��x]�r����kS�Q ][{е9�Gtm�A���е�]�C@��tm�Q ][{е�G!tm�A�����um�Q][{еwpؗ���D��B:8��k��B��ڃ�-bg ~�um����׵e���Ot^QB��tmI�!���+J���Ot^Qrg~��������kK���Ot^QB$��׵%�GA�x][B$��׵�GA�x][A$��׵�G��$�k��38=���;8}�s���pp���`�O���Ot�9���X���������s֟���'�����Eo8���?�c�#N$?g��q"�C�?��b�	�����ZEǟ1�G����*�����?�X~B�?��b�	�Q���k���׵�H~j���ڃU$?5�G�u��*���#�����ֵ5�G�u��*����׵�X~B�_��b�	��]�ZE���#���`�O���ڃU�s�� ��k��� ��`��YD��%���"���O���"���O���"���ڃU,?��3 ?Ѻ6���3 ?Ѻ6���3?�yE@��b���!���+298C��Wd�88C��Wd�� ��`�O��!���+2�Q��"Z�f�� yE����GA�h]�菂�Ѻ6#��+�umF�?
�W$x]���38=�D�s֟���'�����E�8����gp,zÉ�?g��qb�)�!���?g��qb���!���?g��qb���!���?�G�O�׵��(@�I�6c��?	^�f�� �'��ڌA �$x]�1��ğX]�1����k3�Q ]��umƠ?
�k����Gtm�׵��(��M�6��е	^�f�� �6��ڌC@�&x]�q����k3�Q]��umƥ�3�s������6�k���`_���\;8C��k�����x][ B�&tmA���׵sp�'^�����輢 �(��M<��B:8C��W����輢��!���+
��B��    ă�-#g~���� yE��-�?
�W����� yE��-�?
�W����� yE��-�?
�W�t�YǢG�X~�N���t�YǢG�H~��38��Dǟ���E�8����gp,zĉ��?��'��������sޟZ��O���Ot���?
R����(@�I=��
�� �'��k���?�];��(@�I=��1�Ga�O��C@צt��� �6��k��е�];��(��M=��1�Gtm�A׎�?
�kS�v�Q ]�zе5�Gtm�A���е�][Bצtm���;^����е�][g�}	�kk���O�����3 ?��(��M=��Z;8��k�(rp�'Z��qp��'6��#��B���k�98C��W�wp��'6��#���Ol^�G��е)^��rp��'6��#菂�Ѻ6��?
�WD�ڜ@$��ֵ9��(H^����\vv;���v�"�J��֪�#�"E�-ұ#��;��E"��!Qק�>�r�YL{�0Y����kq�Eyd���{�(�#�w��{�x�Ϡ'�I�3�����^;��3�s��[N�|����}=�`N:�k��O|�|�Ϡ'�	���>��x,'�>�g����|�AO<��Χ��p�l�׎�<2�?ﵣ*����{���#����^;���p�l�׎�<��?i�Myd�ﵣ)��v�v4呡�n�׎�<2�ڍ��єG�^��^;����k7�kGSz��{�h�#C��x�Myd�ﵣ	��v�vĵ�4��q�!<r�ڍ��u�i���{툶�t�'��#b�i�O�kG��v�vD�r���1�����v�-�c>�w�9z�v���k��O�]1˖�1���b�-�c>�w�9z�v����r:�WL��"�Syd���{�TY�+�^;�G��N��"ﵻ���]1�����ă9�|>�g����|�AO<���gl9�����ă9�|�-�c>����>��x0'�Ϲ�t�'�>�g����|�AO<���P�q���#��3��Cyd�Ɓ^{(���8�k���z��<��?q�=�G�^;��Cyd��@�=�G�^;��Syd��@�=�G�^;��Syd��@�=�G�^;��Syd��@�=�G�^;��Sx���@�=ǖ��s��9z�8�kϵ�4�^�������Ľ�*[N�|�^{	��v�W�r���+�������-�c>�w�%<r��q��^c��O�]q�-�c>�wŵ�������9z��v^e��O�]1/��"��RY�+�^;/��"��RY�+�^;/��"��R�+&���>��x0'�ϵ�<>��{�|�Ϡ'�	���>��x,'���}=�`N8����ă9�|Ɩ�1��������c9����>��x0'�ϱ�t�'�������΢<2�?���Y�G��g�^;���p�L�kgU��{���#�����Y�G�^;y��Uyd赓��Y�G�^;y��Uyd赓��Y�G�^;y��Uyd赓��ٔG�^;y��Myd赓��ٔG�^;y��Mx�赓���b�i���^;����k'ﵳ�-����-�c>i��mn9�{�l�#G����θ����ĽvF�r���u��O�]1�G�^;y��[N�|�[N�|��ѷ�����Cx���@�s��O�]1�G��N��"�Syd���{�TY�+�^;�G��N��b?�k?�g���ٷ���赟�3�s���[N�|����}=�`N8����ă9�|>�g����|�AO<��?��3�s���-�c>���+���~����#���赻��p��z��<2�?��^�+���~���#����Cyd���^{(��v?�k呡��z��<2���@�=�G�^�赇���k���Pz�~���#C����Cyd���^{
��v?�kϲ�4��y�=�G�^��g�r~/�^{Ɩ�1��מ��4�'ﵧ���k���[N�|�^{�-�a>y�=ז�1����9z�~��^e��O�]q�-�c>�w�ն���������k����-�c>�wť<�|W��RY�+�^{)�,�y���G������]���R�+�k���z���l>��}=�`N:���<>������>��x,'����z���t>ǖ�1���ٟ�3�s��\[N�|��g�Ϡ'�	���>��x0'�Ϣ<2�?�{Q�ڽ(����{�^�G����v/�#��s�^����I{�^�G�^{�^�呡����Uyd��{Uz��{�^�G�^{�^�W呡����Uyd��{Uz��{�^�G�^{�^�Wᑣ����un9?w�k�*<r�ڃ�ڽ][N��%�k�V������vou�i�O�k�&<r�ڃ�ڽŖ�0����-����Ľvo}��O�]�	����vos��O�]��-�c>�wŸ������Cx���{�-�c>�w�PY�+�^�����]��=�G���<�|W�v(�,�y��#�w�y��~�Ϡ'�	���>��x0'����z���p>��3��r����}=�`N:���t�'�>�g���ٷ��������z���t>��1�����#��s赻��p��z��<2�?�^�+���y����#��s赻��s�ĽvWz�y����#C�=��]yd��^�+���<�kw呡מz��<2���@�=�G�^{赇���k���Pz�y���#G�=��#����;﵇���k���[N��%�k���t�'���r���Sx���^{�-�a>y�=��0��מm��O�]q
���<�k��r:�W�}��O�]q�-�c>�w�)<r���@�=ז�1����RY�+�^{)�,�y���G��^�#�wE�k/��"ﵗ���]q赟�3�s��[��������ă9�|�-�c>��s<�g��d�9��3�s�����ă9�|���zⱜ��9��3�s���-�c>��s\�#��s�^{\�#��s�^{\�#��s�^{\�#��s�^{����x�=���s����(�#C��x�=����k/�k��<2�ڋ�ڣ(�����(�#C��x�=����k/�k��<2�ڋ�ڣ(�������#C��x�=����k/�k�Z����;�G9z��{�Qc�i���{�Qs��O�k�ڷ���Ľ���#G��x�=��r��ڣ�-�a>q�=ڵ�t�'��؄G�^{�^{���t�'���ږ�1���b�-�c>�w�&<r�ڋ�ڣ�-�c>�wŦ<�|WĽ�h�#�wE�k��<�|WĽ���"�G(�,�q�=Byt��b�x�=�3l'�I�3�����u*���r���שt>���1����x�a;�`N:�s��O|�|�ϰ�x0'����ۉ�r����}��ă9�|>�g�N<��g*���?_���T���=�?Syt���:�Χ�����u*�O������T:��#���ک<:�k�N��ٕG�{�שp>���|��:�gW��ߞ�{��<:�k�N��<:�k�N��<:�k�N��<:�k�=��]yt��~�J�Sxd�_�ҟ��r~���#C��:��G�r~/�^{�-�c>q�=ږ�0����#C��:��gn9��{�ѷ�����[N�|��Cxd�_���\[N�|����r:�W�e��O�]q
����T8��m9�+N��"ﵧ���]���Syd���{��<�|W��TY�+�^{*��ˁ^��>�v���p>�3l'�	���>�v���p>�3l'ˉ����[N�|����}��ă9�|�-�c>����>�v���t>ז�1���9/���Yx�=/���Yx�=/���Yx�=/���Yx�=/���Yx�=/���I{�y)��v����G�^��^{^�#C�]x�=/呡�.�מEyd��gQz��{�Y�G�^��^{呡�.�מEyd��g9z��{�Y����sǽ�,�#G�]x�=��r~/�^{���t�'��g�����Ľ���#G�]x�=k�r��ڳ�-�a>q�=kl9�I    �+�*<r�څ�ڳ�-�c>�w�Yǖ�1����s��O�]qVᑣ�.�מ��r:�Wl�#�wE�kϦ<�|WĽ�l�#�wE�kϦ<�|WĽ�l�#�wE�kϦ<2|W��מ�����9�����^{>�g�N<����}���c9����>�v���p>�3l'�	���>��x0'���r:��?��3�s���[N�|��g(���z�����Y�ڡ<2�?�^;�G��g=�k���p��z�Ty�N呡׮z�Tz�z��N呡׮z�Tz�z��N呡׮z�Tz�z��N呡׮z��<2���@�ݕG�^�赻���k��vo[N�ϝ��]x���^����{��ڽo9�{�>�����v9z�z���k�i�O�k�k�i�O�k���t�'��8�G�^��G�r:�W��t�'��8r��O�]q��v=�k���t�'��8�G���#�wE�kO��"ﵧ���]���Syd���{��<2|Wlz���z���t>s�y|>ہ^��>��x0'�ϱ�t�'�>�g��󹶜�������z���p>��3��r����}=�`N8����ă9�|*���v��^�#���赗��p�lz��<2�?ہ^{)���v��^�#������Rz��{�u)��v����G�^��^{]�#C��x��.呡�n��^����k7�k�Kyd��ץ<2�ڍ���Rz��{�u	��v��*ז��sǽ�*�#G��x��J�r~/�^{���t�'��W�-�a>q������k7�k�ҷ���Ľ�*c�i�O�k�2������W9z��{�U�-�c>�w�U˖�1����u��O�]qUᑣ�n��^5������WUY�+�^{U��"�WUY�+�^{U��"�WUY�+�^{5��b�^{=�g����|�AO<����}=�`N:���t�'�>�g���ٷ��������z���t>��1����|�AO<����}=�`N8��<2�?���+�G��g�^{���p��k�P��{��#��3x��By��^;�G�^;�ڡ<2��q��呡׎�v*��v�Syd��@���#C�z�Tz�8�k����kǁ^;�G�^;��)<r��q��α�4��y���#G�z�\[N��%�k�k��O�k���4�'ﵻ���kǁ^��-�a>y��c�i�O�k��r:�W��#G�z�>��������r:�W�k��O�]q��v�G�r:�W�#�wE�k��"﵇���]���Cyd���{��<�|W��P�+�^��>��x0'�ϵ�<>�y��~�Ϡ'�	���>��x,'�>�g����|�AO<���gl9������c9����>��x0'�ϱ�t�'�N����z��<2�?�@���G��g赗��p����R�y��^�#����Kyd��@���G�^;��Kyd��@���G�^;��Kyd��@���G�^;q�ݮKyd���wN呡�N�k�9�G�^;q����<���e���;�����<�o8�XNx��sv�y�^��T�s[γ��ޝ�~/��y��p���t>ז��|��a+_�L��ă9�|~�3�����5��N<����<�o8�XN�]�����w�w����-�c>�w�;g�r:�~W�s�-�c>�w�;甜��+�;����r:�~Wl�)��O��7�s*��O��7�s*��O��7�s*��O��7�s*��O��7�s*�<�O�]�Ω<:�]�ݩt>�G��+�;�Χ���w�w���T����:~Wl%�G��+�;�g(�NW|w*��P�����T8��<:�]�u*��XByt���S�|*��e>;�O�Q��g��<��x>�G�2�ϧ�hX�s��L�Ѱ���ʣa��I�3�G�2���g*��e>'�O��i/�ݩt>�G���שЋ�s*�N{��N��<:�E�;�Χ����T:�ʣ�^�W��u���ă9�|���4�g��Q�[N�|����t�'�X������[N�|����-�c>q�ǖ�1��?�£b�
���r:��GCyd�
����呥?*�?�#KTp4�G�����h(�,�Q���PY������<��G�GCyd�
����M呥?*�?��#KTp4�G�����h*�,�Q���TY������<��G�GSyd�
����M呥?*�?��#KTp��G�����h)�,�Q���RY������<��2���;�������*��#K/C߫�s*�,�}��Ω<��2���;�������*�£��U�;��g��-�a>�{�wβ�4�'}���Y������L��G�߫|w*���r:��2��-�c>i/S���t�'�e�%<:�^�S�|�-�c>i/S/呥��^y-�#K/���Z�G�^{�(�,���kQYz�ע<2�2�{���>��x0'�Ͼ�<>��{���>��x0'�Ϲ�t�'�>�g����|�AO<����}=�`N8�����c9����>��x0'���r:��?���p�l�+�Uyd�6�ת<2�?��kU{�*���ƽ�ڔG��'��Myd�j�+�Myd�j�+�Myd�j�+�Myd�j�+�Myd�j�+�Myd�j�+�Myd�j�+�Myd�j�+�Myd�j�+��<2�5��P����k(�{A�{�5�G���ƽ��#�^P�^y�a/�q����ȰԸW^Cyd�j�+��<2x�{�5�G���ƽ��#��R�^yM�a�q����Ȱ�ԸW^Syd�_j�+��<2�/5��9��ƽ�}�i�O��[N�|b����r:��G)<rx�{�_[N�|����-�c>q���1��?��#�W޸W^{l9����<��G�+�]yd鏰W^����a��v呥?�^y��#K���:�G��{�u(�,����PY�#�ס<��G�+�Cyd鏰W^����a��呥?�^y�#K���:�G��{�u(�,����TY�#�ש<��G�+�Syd鏰W^����a��N呥?�^y��#K���:�G��{�u*�,����TYz�ש<��2�+�Kyd�e�W^�����`��.呥��^y]�#K/���G����Wn9�ɽ�շ����^�[N�|�^f	�^y;�����t�'�e�um9�I{�v�-�c>i/�.��+o�+oW�r:��2�RYz앷Kyd�e�W�.呥��^y��G�^{��RYz앷Kyd�e�{���>��x0'����z���p>��3�s��|�Ϡ'�I���>��x0'���r:��?��3�s��[N�|����}=�`N:�k��O|���#��3�Wު��p��<2�?�{�*����^y��#��3�Wު��s��{A�*�{A���V�G����^y��#�^Pp��U�a/(�Wޚ�Ȱ�+oMyd�
�<2���[S���{�)�{A���֔G����^yk�#�^Pp��5�a/(�Wޚ�Ȱ�+oMyd�
P���{�-�G����^y�a/(�W�Byd�ʃ{�-�G����^y�a)�W�Byd�_
P���{�-�G����^y�a)�W�Rx��ʃ{�-˖�0��+oY�����^y˶�t�'�Rx��ʃ{�-s��O�e�r:��G9������Q
�^yp����r:��G]yd鏰W޺���a��u呥?�^y��#K���֕G��{�+�,���[WY�#앷�<��G�+o]yd鏰W޺���a��呥?�^y�#K���6�G��{�m(�,����PY�#앷�<��G�+oCyd鏰Wކ���a��呥?�^y�#K���6�G��{�m*�,����TY�#앷�<��2�+oSyd�e�Wަ����`��M呥��^y��#K/���6�G�^{�m
�^yp���k�i�O앷U�����^y[u��O��,��+[N�|�^f��1���Y}��O��,��+�^��[N�|�^f)�,����RYz�ǥ<��2�+�Kyd�e�W�����`�<.呡�I���}=�`N:�}�y|>�{��|�AO<�����r:��?��>��x0'��    ��z���p>��3�s��|�Ϡ'�I��|�AO<���gl9�I�Q�G��gr�<���p�L�GQ�ɽ�(�#��3�WEyd�&�ʣ*�<�O�Uyd�J�GU���{�Q�G����^yT�a/(�WUyd�J�GU���{�Q�G����^yT�a/(�WUyd�J�GS���{�єG����^y4�a/(�WMyd�J�GS���{�єG����^y4�a/(�WMyd�J�GS���^y4�a)�W�<2�/%��#�G����^y��Ȱ���+�P���{��#��Rr�<Bx��ʓ{�}�i�O�G�-�a>�W1������Q�^yr�<��r:��GY������Q�-�c>q��#�W��+��-�c>q��#K���H呥?�^y����a�<Ryd鏰W�<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��2�+��<��2�+��<��2�+��<��2�+��<��2�+��<��2�+�)<rx�ɽ��4�'��c�-�a>�Wsl9�{�)<rx�ɽ�k��O�ˬk��O�ˬ��t�'�e����'��c�-�c>q/��G�^�{�Kyd�e�W��G�^�{�Kyd�e�W��G�^�{�Kyd�e:����>��x0'��|�Ϡ'���3��3�s�����zⱜ������ă9�|��1�������ă9�|�-�c>��3��3�s��\[N�|��g���ٹW�Eyd�v�gQ{�Y�G��g�^y���ٹW�Ey�ҽ�,�#�^P�^y�a/�s�<��ȰԹW�Eyd���+Ϫ<2�u�gU��:�ʳ*�{A�{�Y�G���ν��#�^P�^yV�a/�s�<��ȰԹW�Uyd���+Ϫ<2�u�gU��:�ʳ)�{A�{�ٔG���ν�l�#�^P�^y6��+��+Ϧ<2�/u�gS��:�ʳ)��K�{�ٔG���ν�l�#��R�^y6�a�s�<Cx���;��3ʖ�0��+Ϩ[N�|b�<�m9���9��ν��r:��Gѷ�����Q�-�c>q�#�W޹W��������Q*�,���3�G��{��#K���L呥?�^y����a�<Syd鏰W��<��G�+�TY�#�g*�,���3�G��{�ٕG��{�ٕG��{�ٕG��{�ٕG��{�ٕG��{�ٕG��{�ٕG��{�ٕG��{�ٕG��{�ٕG��{�9�G��{�9�G��{�9�G��{�9�G�^{�9�G�^{�9�G�^{�9�G�^{�9�G�^{�9�G�^{�9�G��s�<��4�'��s�-�a>�W��n9�{�)<rx�{�9c��O����r:��2�o9�{�)<rx�{�9��1�����#K/���\�#K/���\�#K/���\�#K/���\�#K/���\�#C/3x����ă9�|�-�������z���t>��1����|�AO<���g�Ϡ'���?�g��d�ٟ�3��r��g�Ϡ'�I�3�������~)������~)������~)������~)������~)������^�G��'��Eyd��+�Eyd��+�Eyd��+�Eyd��+�Eyd��+�Eyd��+�Eyd��+�Eyd��+�Eyd��+�Uyd��+�Uyd��+�Uyd��+�Uyd��+�Uyd��+�Uyd��+�Uyd��+�Uyd��+�Uyd����{U����{S����{S����{S����{S����{S����{9���������0��+�ml9�����1��?�Mx�����{\[N�|��(ʖ�1��?���t�'�Bx�����{Ė�1��?
呥?�^y呥?�^y呥?�^y呥?�^y呥?�^yO呥?�^yO呥?�^yO呥?�^yO呥?�^yO呥?�^yO呥?�^yO呥?�^yO呥?�^yO呥?�^yO呥?�^y��#K���ޕG��{�+�,���{WY�#���<��G�+�]yd鏰W޻���a��w呥?�^y��#K/���ޕG�^{�}(�,����PYz���<��2�+�Cyd�e�Wއ������[N�|b�����4�'���[N�|�^f�^��^yk��O���k��O��̲�t�'�e������ٶ���Ľ�TYz���<��2�+�Syd�e�Wާ����`��O呥��^y��#C/3�Wޟ�3�s��|�Ϡ'�	���>��x0'����zⱜ���|�AO<���gn9�����ă9�|�-�c>����>��x0'�ϵ�t�'��Kyd�NKyd�NKyd�NKyd�NKyd�NKy�ҽ�q)�{A�{��R��&��ǥ<2�MKyd���+Eyd���+Eyd���+Eyd���+Eyd���+Eyd���+Eyd���+Eyd���+Eyd���+Eyd���+Eyd���+Uyd���+Uyd���+Uyd���+Uyd��'��GU��&��GU��&��GU��&��GU��&��GU��&��GU��&��G9��ɽ��ʖ�0��+�n9���ږ�1��?Mx���'��G�-�c>i4Z�r:��G��-�c>i4����O�������Q(�,���G(�,���G(�,���G(�,���G(�,���G(�,���G(�,���G(�,���G(�,���G(�,���G*�,���G*�,���G*�,���G*�,���G*�,���G*�,���G*�,���G*�,���G*�,���G*�,���GWY�#앏�<��G�+]yd鏰W>�����`�|t呥��^���#K/���ѕG�^{�+�,���GWYz앏.<rx�{�c\[N�|b�|���4�'��Ǩ[N�|�^f�^��^���t�'�eFn9�{�ѷ���Ľ�9��ɽ�1��1����#K/���1�G�^{�c*�,����TYz앏�<��2�+Syd�e����}=�`N:�}�y|>����}=�`N:�s��O|�|�Ϡ'�	���>��x0'����z���p>��3��r����}=�`N:���t�'�.����x�Kyd��^�R��W��G���:��/�����W>/���I���<2�-��Kyd�Z�+���Ȱ��W>/�a/hq�|^�#�^��^���G���Ž�y)�{A�{��R�����<2�-�Ϣ<2�-�Ϣ<2�-�Ϣ<2�-�Ϣ<2�-�Ϣ<2�-�Ϣ<2�-�Ϣ<2�-�Ϣ<2�-�Ϣ<2x�{�(��K�{�*��K�{�*��K�{�*��K�{�*��K�{�*��K�{�
�^��^��}�i�O��:�����^��s��O��*<rx�{�][N�|��h���t�'�f�[N�|��h6��+_�+�-�������l�#K���ٔG��{�)�,���gSY�#�Ϧ<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��G�+��<��2�+��<��2�+�]yd�e�W>�����`�|v呥��^���#K/���مG�|q�|��r�{��-�a>�W>��r:��2]x�����g_[N�|�^f\[N�|�^f�-�c>q/3�G�|q�|���t�'�e�����`�|呥��^��#K/���9�G�^{�s(�,����P��e�Ž��x�a;�`N8�������x�a;�`N8�����������ۉs���-�c>����>�v���t>ǖ�1����x�a;�`N:�k��O|�\ʣ���שp>������������G�S�|.������T    :�ʣ���שt>�G��'�Zʣ�{A�S�|*����N��<:��:�Χ���^��S�^к�G���^���\����^��T6��R��z���s]ʣ�{AoO�{A�R��z�J�Syt~/�u*�O�����שt>�G���ޞJ��֥<:��:�Χ���^��T8�Eyt~/�u*�Ϣ<:���T������^��T8�Eyt�+�J�Syt~�u*�O����������U�G���^���T��_z�J�Syt~�u*�O������T앯*<2x�S�|ֲ�4�'��W�[N�|b�|ն�t�'�V��שt>s��O��ڷ�����Ѫc��O��*<2x�S�|�-�c>i�����a�|5呥?�^�j�#K���ՔG��{�)�,���WSY�#앯�<��G�+_Myd鏰W�����a�|5呥?�^�
呥?�^�
呥?�^�
呥?�^�
呥?�^�
呥?�^�
呥?�^�
呥?�^�
呥?�^�
呥?�^�
呥?�^�J呥?�^�J呥?�^�J呥?�^�J呥��^�J呥��^�J呥��^�J呥��^�J呥��^�J呥��^�J��+�
�_[N�|b�|���4�'��W�[N�|�^��^��T:���t�'�ezn9�{�޷���ĽL��שt>��1�����#K/���5�G�^{�k(�,����PYz앯�<��2�+_Cyd�e
����}��ă9�|�-���,�+_�����9���������ۉs��|�Ϡ'�	���>��x0'����zⱜ���|�AO<���gl9��Syd��<2�?���T{�k*���½�5�G��g�^�Z�#���-�a/�p�|-�a/�p�|-�a/�p�|-�a/��ʗ�ȰTx�Kyd�*��<2��^�R����|)�{A{�q]�#�^P�^��Syd�*�+�s*�{A{�wN�a/�`��Ω<2���9�G������;��ȰT�W~�T��
����#�W^�W~�T��
���*�#��R�^��Syd�_*�+�s*��K{�wN�a�`��Ω<2�/��9�G��`���ٷ����^��sl9�I��;��r:��GwN��+/�+��^[N�|����Y������ѝ�n9�	��;������9c��O��9�G���z�wN呥?�^��Syd鏨W~�TY�#��9�G���z�q5呥?�^��Syd鏨W~�TY�#��9�G���z�wN呥?�^��Syd鏨W~�TY�#��9�G���z�wN呥?�^��Syd鏨WW(�,�����#KD��;����Q��Ω<��G�+�s*�,�����#KD��;����Q��Ω<��G�+�s*�,�����#K/C��Ryd�e�W~�TYz��9�G�^�z�wN呥��^��Sx������4�'���}�i�O��9ǖ�1���I��+/�+�s�-�c>q/ӯ-�c>q/�˖�1�����#�W^�W~�l[N�|�^�+�,�����#K/C��;�����P��Ω<��2�+�s*�,�����#C/S�W��}=�`N8����ă9�|>�g����|�AO<��?��3�s���-�c>����>��x0'�ϱ�t�'�>�g��󹶜����ϩ<2�?+����#���b��Ω<2�?+����#���b��Ω<2�?+����#���M�a/�b��Ω<2�U��9�G������;��ȰT�W�R��*����#�^P�^��Syd���+�s*�{A{�wN�a/��ʗ�ȰTx�Kyd����<2��^�R����|)�{A�{��R��*��˥<2�UKyd���+/�����WKyd�_��+/��Ȱ�T�W^.�a�r��\�#��R�^y��G���ʽ�r)��K�{��^y�^y)e�i�O앗R�����^y)m��O��"<rx�{���1��?*�o9�I��RƖ�1��?*Ex���+��KY[N�|���T呥?�^y��#K���R�G��{�*�,���KUY�#앗�<��G�+/Uyd鏰W^����a��T呥?�^y��#K���ҔG��{�)�,���KSY�#앗�<��G�+/Myd鏰W^����a��4呥?�^yi�#K���ҔG��{�)�,���K(�,���K(�,���K(�,���K(�,���K(�,���K(�,���K(�,���K(�,���K(�,���K�^y�^y�k�i�O앗,[N�|b��d�r:��2)<rx�{�%c��O��dn9�{��[N�|�^&�G��r����r:��2�<��2�+/]yd�e�W^�����`��t呥��^y��#K/���ҕG�^�q��<�g���ٷ���q��<�g���9���������z���p>��3�s��|�Ϡ'�	���>��x,'�>�g���[N�|���P{�e(���ƽ�2�G��g�^y�#���q�����ٸW^���s��{ASyd�j�+/Syd�j�+/Syd�j�+/Syd�j�+/Syd�j�+/Syd�j�+/Syd�j�+/Syd�j�+/Syd�j�+/Kyd�j�+/Kyd�j�+/Kyd�j�+/Kyd�j�+/Kyd�j��<2��^�R����|)�{A�W��G���ʗ�Ȱ�ԸW^/�a�q��^�#��R�^y��G���ƽ�z)��K�{��R�����%<rx�{���[N�|b��^c�i�O��kn9�I��z	�^y�^y-ז�1��?��l9�I��Z��1��?�Ex�����k�-�c>iT����a��呥?�^y-�#K���Z�G��{�(�,���kUY�#�ת<��G�+�Uyd鏰W^����a��V呥?�^y��#K���Z�G��{�*�,���kUY�#�ת<��G�+�Myd鏰W^����a��6呥?�^ym�#K���ڔG��{�)�,���kSY�#�צ<��G�+�Myd�e�W^�����`�������`�������`�������`�������`������7���-�a>�W^�o9��c��O�˄���7��X[N�|�^&�-�c>q/�e��O�ˤ���7��l[N�|�^&�G�^{�5�G�^{�5�G�^{�5�G�^{�5�G�^{�5�G�^&�W^��3�s��|�Ϡ'�	���>��x0'����zⱜ���|�AO<���gn9�����ă9�|�-�c>����>��x0'�ϵ�t�'�����+�Cyd����P����:�G��gp������+�Cy�⽠�<2����P���{�u(�{A���:�G����^y��#�^Pp��N�a/(�W^��Ȱ�+�Syd�
�ש<2����T���{�u*�{A���:�G����^y��#�^Pp��N�a/(�W^��Ȱ�+�Kyd�
�ץ<2����R���^y]�#��R�ʗ�Ȱ���<2�/��|)��Kq�+_�#��R�ʗ�Ȱ��+o�������U�����^y���0��+oW�r:��G�9���^y�r��O���o9�I��v�-�c>i�.��+km9�I��V�G��{�(�,���[QY�#앷�<��G�+oEyd鏰Wފ���a��呥?�^y+�#K���V�G��{�(�,���[UY�#앷�<��G�+oUyd鏰Wު���a��U呥?�^y��#K���V�G��{�*�,���[UY�#앷�<��G�+oMyd鏰Wޚ���a��5呥?�^yk�#K/���֔G�^{�)�,���[SYz앷�<��2�+oMyd�e�Wޚ�����[\[N�|b��E�r�{�-��1���	��+�-�c>q/��t�'�e�o9�{�9���^y���t�'�eByd�e�W�Ryd�e�W�Ryd�e�W�Ryd�e�W�Ryd�e�W�Ryd�e�{���>��x0'�Ͼ�<>�ɽ��|�AO<�����r:��?��3�s��|�Ϡ'�	���>��x0'����zⱜ���|�AO<���gl9��]yd�&��[W�ɽ�֕G��    gr��u�����+o]yd�&���Py�x/h(�{Aɽ�6�G����^y�#�^Pr���a/(�Wކ�Ȱ��+oCyd�J�<2�%���P���{�m(�{Aɽ�6�G����^y��#�^Pr��M�a/(�Wަ�Ȱ��+oSyd�J�<2�%���T���{�m*�{Aɽ�6�G�<�Wަ�Ȱ���+oKyd�_J�<2�/%���R���{�m)��Kɽ�G���<��/��+�^��[N�|r�|�-�a>�W���1��?Z�#�W��+���r:��Gq�-�c>iW�r:��Gq	�^yr�<��r:��Gq)�,����RY�#�ǥ<��G�+�Kyd鏰W����a�<����a�<����a�<����a�<����a�<����a�<����a�<����a�<����a�<����a�<����a�<����a�<����a�<����a�<����a�<����a�<����a�<����a�<����a�<�����`�<�����`�<�����`�<�����`�<�����`�<�����`�<����'�ʣ��0��+�ַ����^y���t�'�e�	�^yr�<��r:��2qm9�{�([N�|�^&�G�<�WѶ���ĽL(�,���#�G�^{��#K/���呥��^y�����`�<Byd�e:����>��x0'����z���p>��3�s��|�Ϡ'ˉ����ă9�|��1����|�AO<�����r:��?��3�s��\[N�|��gW{�ѕG��g�^yt���ٹW]yd�v�GW{�ѕG��'���#�^P�^yt�a/�s�<��ȰԹW]yd���+��<2�u��P��:��c(�{A�{�1�G���ν��#�^P�^y�a/�s�<��ȰԹWCyd���+��<2�u��P��:��c*�{A�{�1�G���ν��#�^P�^yL��+��+��<2�/u��T��:��c*��K�{�1�G���ν��#��R�^yL�a�s�<����w��*[N�|b�<V�r�{�ږ�1��?Z�#�W�x�+��������[N�|��h�-�c>q��G������r:��Gy)�,����RY�#��<��G�+�Kyd鏰W�����a�</呥?�^y^�#K���G��{�y)�,����RY�#�gQY�#�gQY�#�gQY�#�gQY�#�gQY�#�gQY�#�gQY�#�gQY�#�gQY�#�gQY�#�gUY�#�gUY�#�gUY�#�gUYz�gUYz�gUYz�gUYz�gUYz�gUYz�g9��ν�lז�0��+�V�����^y���t�'�e�	�^y�^y��r:��2�r��O��d�[N�|�^&����w�g�[N�|�^�)�,���3�G�^{��#K/���呥��^y�����`�<Cyd�e����>��x0'�Ͼ�<>��{��|�AO<�����r:��?��3�s��|�Ϡ'�	���>��x0'����zⱜ���|�AO<���gl9�<2�?��3�G����^y���p��+�T{��#��sp�<���s��{A]yd��+Ϯ<2��gW���ʳ+�{A�{�ٕG��������#�^��^yv�a/hp�<��Ȱ4�W�]yd��+ϡ<2���P����s(�{A�{�9�G�������#�^��^y�a/hp�<��Ȱ4�W�Cyd��+ϡ<2x�{�9�G�������#����^yN�aip�<��Ȱ�4�W�Syd�_�+ϩ<2�/��9�����}�i�O��[N�|b�<��r:��GSx�����s][N�|��h�-�c>q���1��?Z�#�W>�W�+�������RY�#�/呥?�^�RY�#�/呥?�^�RY�#��Kyd鏰W�/呥?�^y��G��{��RY�#��Kyd鏰W�/呥?�^y��G��{��RY�#��Kyd鏰W�/呥?�^y/�#K���^�G��{�(�,���{QY�#���<��G�+�Eyd鏰Wދ���a��呥?�^y/�#K/���^�G�^{�*�,���{UYz���<��2�+�Uyd�e�Wޫ������[N�|b��׾�4�'��{[N�|�^�W��+�+�um9�I{�ޮ-�c>i/�[�r:��2�	�^��^yom��O����<��2�+�Myd�e�Wޛ����`��7呥��^yo�#K/���ޔG�^fr��?�g����|�AO<����}=�`N8�����c9����>��x0'���r:��?��3�s��[N�|����}=�`N:�k��O|�L���9�W�Syd�N��T{�=�G����^yO���9�W�Sy�⽠T��&��{*�{A�{�=�G���ɽ��#�^��^y��#�^��^y��#�^��^y��#�^��^y��#�^��^y��#�^��^y��#�^��^y��#�^��^y��#�^��^y��#�^��^y��#�^��^y�#�^��^y�#�^��^y�#�^��^y�#�W>�Wއ�Ȱ�4�Wއ�Ȱ�4�Wއ�Ȱ�4�Wއ�Ȱ�4�Wއ�Ȱ�4�Wއ�Ȱ�4�Wާ���O��Y�����^y�u�i�O��ٶ������9��ɽ�>s��O�;�t�'���r:��GSx���'���\[N�|��h)�,����RY�#���<��G�+�Kyd鏰Wޗ���q�|)�,��ʗ���q�|)�,��ʗ���q�|)�,���ǥ<��G�+����a�|\�#K���q)�,���ǥ<��G�+����a�|\�#K���q)�,���ǥ<��G�+����a�|呥?�^�(�#K���Q�G��{�(�,���GQYz앏�<��2�+Eyd�e�W>�����`�|呥��^�(�#�W>�W>��4�'��G-[N�|b�|Ժ�t�'�eF9��ɽ�Qc��O�ˌ�[N�|�^fԾ�t�'�eF9��ɽ�Q��1���Uyd�e�W>�����`�|4呥��^�h�#K/���єG�^{�)����^�x�Ϡ'�I�o9����^�x�Ϡ'�I�sn9�����ă9�|>�g����|�AO<����}=�XN|�|�Ϡ'�I�3�������P{�#�G����^������W>Byd�.P{�#�G��'��<2�-T����G*�{A�{�#�G���Ž��#�^��^�H�a/hq�|��Ȱ��W>Ryd�Z�+�<2�-�<2�-�<2�-�<2�-�<2�-�<2�-�<2�-�<2�-�<2�-�<2x�{�+��K�{�c(��K�{�c(��K�{�c(��K�{�c(��K�{�c(��K�{�c�^��^�}�i�O앏1�����^�s��O���+_�+��r:��G�l9���Y�������9��Ž�1c��O�M呥?�^���#K���1�G��{�c*�,����TY�#앏�<��G�+Kyd鏰W>����a�|,呥?�^�X�#KĽ�<��G�+_�#KĽ�<��G�+_�#KĽ�<��G�+�����a�|^�#K���y)�,����<��G�+�����a�|^�#K���y)�,����<��G�+������`�|^�#K/���Y�G�^{�(�,���gQYz�Ϣ<��2�+�Ex�����g�-�a>�W>K�r�{峌-�c>i/3����/�ϲ������̬ז�1�����l9�I{�Y�G�|q�|ֶ�t�'�efUYz�Ϫ<��2�+�Uyd�e�W>�����`�|V呥��^��ʣ�L��W>�3l'�	���>�v���p>�3l'�	���>�vⱜ���x�a;�`N:���t�'�>�g�N<�����r:��?�3l'�I�sm9�<:�|�
�3�G��oO���P���N��ʣ���שt>�G�S�|*�<�O�4Cyt~/�u*�O�����שt>�G���^���T��z{*���<:��:�    g*����N��ʣ�{A�S�|����^��S�^�L�����שt>�G���^���T��z�J�Syt~/���x/(�G���^���T��z�
�+����N��ٕG���ޞ�������^��T8�]yt�+�J�Syt~�u*�O�����������<:���:�Χ������T:�ʣ��K�S�|*���/ݧb�|��+�
�s�-�a>�W>G�r�{�s�-�c>q4�G��u*���r:��G�o9���1���������שt>ז�1��?��#K���9�G��{�s*�,����TY�#�ϩ<��G�+�Syd鏰W>����a�|N呥?�^���#K���9�G��{�s)�,����RY�#�ϥ<��G�+�Kyd鏰W>����q�|)�,��ʗ���q�|)�,��ʗ���q�|)�,���ץ<��G�+_����a�|]�#K���u)�,���ץ<��2�+_�����`�|]�#K/���u)�,���ץ<��2�+_������N��Y�-�a>�W�J�r�{��-�c>i/�������N��[N�|�^f��r:��2��-�c>i/�������N��9�������*�#K/���U�G�^{�*�,���WUYz앯�<��2�+_Uyd�e
����}��ă9�|�-���,�+_�����9���������ۉs��|�Ϡ'�	���>��x0'����zⱜ���|�AO<���gl9��Myd��<2�?��WS{�)���½�ՔG��g�^�
���I��V(�{A�{�+�G���½��#�^P�^�
�a/�p�|��ȰT�W�Byd�*�+_�<2�P��
��W(�{A�{�+�G���½��#�^P�^�J�a/�p�|��ȰT�W�Ryd�*�+_�<2�T��
��W*�{A�{�+�G��p�|��Ȱ�T�W���Ȱ�T�W���Ȱ�T�W���Ȱ�T�W���Ȱ�T�W���Ȱ�T�W�����޷����^��c�i�O앯>������Q9��½�5�-�c>q4ʖ�1��?u��O���+/�+_#�������PY�#앯�<��G�+_Cyd鏰W�����a�|呥?�^���#K���5�G��{�k*�,����TY�#앯�<��G�+_Syd鏰W�����a�|M呥?�^���#K���5�G��{�k)�,����RY�#앯�<��G�+_Kyd鏰W�����q�|)�,��ʗ���q�|)�,��ʗ����p�|)�,����G�^�z�wN呥��^��Syd�e�W~�TYz��9�G��`��Ι[N�|R���ٷ����^��sl9�	{�;������9ז�1���ɫ\[N�|�^��Y������̝Sx������m��O���9�G�^�z�wN呥��^��Syd�e�W~�TYz��9�G�^�z�wN呡���+���>��x0'����z���p>��3�s��|�Ϡ'ˉ����ă9�|��1����|�AO<�����r:��?��3�s��\[N�|��gS�{�wN���Y�W~�T�{�wN���Y�W~�T�{�wN���	����#�^P�^��Syd���+�s*�{A{�wN�a/�b�<�P��*����#�^P�^��Syd���+�s*�{A{�wN�a/�b��Ω<2�U��9�G������;��ȰT�W~�T��*����#�^P�^y^�<2�U��9�G������;��ȰT�W~�T���;��Ȱ�T�W~�T��*����#��R�^��Syd�_��+�s*��K{�wN�a�b�<�.<rx�{�wβ�4�'���u�i�O��9ۖ�1��?��#�W^�W~��-�c>q����1��?�c��O�u��+��+�s�-�c>q4�G���z�wN呥?�^��Syd鏨W~�TY�#��9�G���z�wN呥?�^��Syd鏨W~�TY�#��9�G���z�wN呥?�^y^Syd鏨W~�TY�#��9�G���z�wN呥?�^��Syd鏨W~�TY�#��9�G���z�wN呥?�^��Syd鏨W~�TY�#�絔G���z�wN呥?�^��Syd鏨W~�TYz��9�G�^�{�Kyd�e�W��G�^�{�Kyd�e�W��G�^�{�Kx���+���um9��r�-�a>�W^���t�'�e�%<rx�{��-�c>i/S��r:��2��[N�|�^�\�#�W^�W^���t�'�eʥ<��2�+/Eyd�e�W^�����`��呥��^y)�#K/���R�G�^�q��<�g���ٷ���q��<�g���9���������z���p>��3�s��|�Ϡ'�	���>��x,'�>�g���[N�|��gU{�*���ƽ�R�G��g�^y��#���q��T���ٸW^���s��{A�)�{A�{�)�{A�{�)�{A�{�)�{A�{�)�{A�{�)�{A�{�)�{A�{�)�{A�{�)�{A�{�%�G���ƽ��#�^P�^y	�a/�q����ȰԸW^Byd�j�+/�<2�5P����K(�{A�{�%�G��q����Ȱ�ԸW^Ryd�_j�+/�<2�/5T����K*��K�{�%�G���ƽ��#�W޸W^�o9��c�i�O앗�[N�|��(�G��q���k��O����t�'�z�r:��G]x�����K�-�c>qԕG��{�+�,���KWY�#앗�<��G�+/]yd鏰W^����a��呥?�^y�#K���2�G��{�e(�,����PY�#앗�<��G�+/Cyd鏰W^����a��呥?�^y��#K���2�G��{�e*�,����TY�#앗�<��G�+/Syd鏰W^����a��L呥?�^y��#K/���2�G�^{�e)�,����RYz앗�<��2�+/Kyd�e�W^���ᕷ^��-�a>�W����0��+_c��O��,��+o�򵶜����L��-�c>i/S���t�'�e�%<rx�{��j[N�|�^�^�#K/���z)�,����<��2�+������`��^�#K/���z)��Lp��>�g����|�AO<����}=�`N8�����c9���>�g���[N�|����}=�`N:�c��O|�|�Ϡ'�I�sm9��Uyd���kU����Z�G��gp��V����+�Uyd���kUy�t/�V�a/(�W^��Ȱ�+�Uyd�
�ת<2���kS���{�)�{A���ڔG����^ym�#�^Pp��6�a/(�W^��Ȱ�+�Myd�
�צ<2���kS���{�)�{A����#�^Pp����Ȱ�+��<2���k(�^yp����Ȱ��+��<2�/��k(��K����#��Rp����Ȱ��+��<2�/��k
�^yp��f�r�{�5��0��+�ٶ�����Q
�^yp��fn9����[N�|��(ǖ�1��?J��+��\[N�|���+�,���kWY�#�׮<��G�+�]yd鏰W^����a��v呥?�^y��#K���ڕG��{�+�,���kWY�#�ס<��G�+�Cyd鏰W^����a��呥?�^y�#K���:�G��{�u(�,����PY�#�ס<��G�+�Cyd鏰W^����a��N呥?�^y��#K���:�G�^{�u*�,����TYz�ש<��2�+�Syd�e�W^�����`��N��+��um9��ʖ�0��+��n9�{�%<rx����b��O�ˬ�r:��2�o9�{�%<rx�q�+_s��O��,呥��^y��G�^{��RYz앷Kyd�e�W�.呥��^y��G�^&�Wޞ�3�s���[����+o���ă9�|�-�c>���=�g����|�AO<����}=�`N8�����c9���=�g���[N�|��g+�#��3�Wފ��p�L�<2�?�{�(����^y+�#��3�Wު��s��{A�*�{Aɽ�V�G����^y��#�^Pr��U�a/(�Wު�Ȱ��+oU �  yd�J�<2�%��[U���{�*�{Aɽ�֔G����^yk�#�^Pr��5�a/(�Wޚ�Ȱ��+oMyd�J�<2�%��[S���{�)�{Aɽ�֔G�<�Wޚ�Ȱ���+o�<2�/%��[(��Kɽ��#��Rr����Ȱ���+o�<2�/%��[�^yr��E�r�{�-Ɩ�0��+o1������Q�^yr����t�'l9����[N�|��(�G�<�W�2������Q*�,���[*�,���[*�,���[*�,���[*�,���[WY�#앷�<��G�+o]yd鏰W޺���a��u呥?�^y��#K���֕G��{�+�,���[WY�#앷�<��G�+oCyd鏰Wކ���a��呥?�^y�#K���6�G��{�m(�,����PY�#앷�<��G�+oCyd�e�Wކ����`��M呥��^y��#K/���6�G�^{�m*�,����9���^y���4�'����[N�|b��ͱ�t�'�e����'���\[N�|�^f][N�|�^f�-�c>q/��G�<�W�V�r:��2Kyd�e�W��G�^�{�Kyd�e�W��G�^�{�Kyd�e�W��G�^�s�<��3�s�����z���l>��>��x0'��x�Ϡ'�I��|�AO<���gn9�I��|�AO<�����r:��?��>��x0'�ϵ�t�'�FQ{�Q�G��g�^y���ٹWEyd�v�GQ{�Q�G��'���<2�u�GQ��:�ʣ(�{A�{�Q�G���ν��#�^P�^yT�a/�s�<��ȰԹWUyd���+��<2�u�GU��:�ʣ*�{A�{�Q�G���ν��#�^P�^yT�a/�s�<��ȰԹWMyd���+��<2�u�GS��ν�h�#��R�^y4�a�s�<��Ȱ�ԹWMyd�_��+��<2�/u�GS��:��#�G��s�<�l9���4�'��#ږ�1��?
��+��+��-�c>q}��O���r:��G!<rx�{�k��O�����a�<Ryd鏰W�<��G�+�TY�#�G*�,���#�G��{��#K���H呥?�^y����a�<Ryd鏰W]yd鏰W]yd鏰W]yd鏰W]yd鏰W]yd鏰W]yd鏰W]yd鏰W]yd鏰W]yd鏰W]yd鏰WCyd鏰WCyd鏰WCyd鏰WCyd�e�WCyd�e�WCyd�e�WCyd�e�WCyd�e�WCyd�e�WCx���;��c^[N�|b�<f�r�{�1��1�����#�W޹W3����Ľ��-�c>q/3���1�����#�W޹Wsn9�{��<��2�+��<��2�+��<��2�+��<��2�+��<��2�+��<2�2�W�|�AO<���g�r��q�+�Ϡ'�I�sn9�����ă9�|��}=�`N6��|�AO<���g>�g�����|�Ϡ'�I�3������ϼ�G����^y^�#��sp�</���9�W����p��+�Kyd��gQy�t/(��Ȱ4�W�Eyd��+Ϣ<2��gQ���ʳ(�{A�{�Y�G������,�#�^��^y�a/hp�<��Ȱ4�W�Uyd��+Ϫ<2��gU���ʳ*�{A�{�Y�G�������#�^��^yV�a/hp�<��Ȱ4�W�Uyd���ʳ*��K�{�ٔG������l�#����^y6�aip�<��Ȱ�4�W�Myd�_�+�&<rx�{�����0��+�6�����^y���t�'폲	�^��^yƵ�t�'l9����[N�|��(�G�|p�<#������Q(�,���3�G��{��#K���呥?�^y����a�<Syd鏰W��<��G�+�TY�#�g*�,���3�G��{��#K���L呥?�^y����a�<Syd鏰W��<��G�+Ϯ<��G�+Ϯ<��G�+Ϯ<��G�+Ϯ<��G�+Ϯ<��G�+Ϯ<��G�+Ϯ<��G�+Ϯ<��G�+/�\o�����j�&��/���_|��g����ߏ�����w�����_���7����>������?���o��/?���z����?�/>��׿�ͯ~���?}�?{��~���~�����A�����G�����/?��_}���~����?��G?��'�}��?��{?������?������|�������?\��?~���}�����߿���x�?�U���rF����I�������?����ǿ��y������g���Wio>�oZ���̟ԏ�������X�^}m��A_�췟���/�m���|��;����?��_����@���CK�����K���?��������q��'�ٗ_��o��;����7��ͷ��_�g}����ŧ�~��z�_}�����������/����o��7?����y����~]����?��~�g_~X���������������}+�/?���o>����w����~����/�5>�V�?��������r�$G|���8޴�b��������q-�~�雫��������k�}c���⽏k�a���Wyo}��G������O���7��廿���w#X��G0����׎^~U*ܿ��ۭ�����O��g�~�۟���XKF�����}����o��Ǽ[�>���_oF���_����;��ߡ����>�ٿ���������[���|�j_� ���C�_W诋������z�_��z�+�g������^ʷK��?����}�?�9�a0��cD�Vv��uQc�����������&�:�:x�>���q961��XkY����"�L�}RW�bj�im:@��zKjnzAD	�1�O1�S��^f�: v�����}1�
t�Yf�s�[��2�	����S!'��O�+��4��дJޘau�ڰ
�j|�j��`�xV{Y%�Xm�5��V�w�>�j�%?�"�`�  �d�sa      8   �  x����r�0�k�)� ��ڤ�f��6��A���Y�~G���������HƘ�S�1ꤽKu�F]���C�k����������6�4�"cЛsm}�B�!TVJk�Y�Z�$�S���X��HcUc�H�^{��]?�j���ۛ�z�X�S�5�1
a��|R!���,���jiM
 ��u_�A�� ��'g�!ɧ2$b�2BL/W��צ���T�ѻ~���Ɋ�Vc��	���J*��JZcMT�Es�\�� �dOI���}YJ \�:J!L�F�$� �?+��ޅ������%�i|k�
�YѠ�q��럖�O�4���r�-�\�e�Ƕ&�cf4�
3��]dc���	 �������6��n��m���M7�W�M�?$^ ��͇�ý�/�1�[�@��ϲ>���ї�/�Җ1|�x�;�d�������K�m�9j��t%�*�	��|?�X��Og�
�Vɂ@>o�Ѿ�ឍւF`�|�gŚ�Y�}=�?�2�      4   )   x�37�41�L�27�43�f��f�J��!�=... �ok      6   �  x���K�$;
E�Q��y[��G������ y�!�v���1��"�/����Ho�7�lH��?��?@��<@��=@�P{�,!}���ϯ�����F�j	Y	��'�v�����d}P��(�AQR�@9��_�~�����_=>PG����
��4)?P�m@�� 5�nyR�@9�4ؒ��`ƴ�d�B���՚u�!Hj�������l?K�IE9牒Z��K�O���Z-�R�ڼ9���Iu@�җ~���ʙ~YR�_7խ�HxR���`5H��V����v���zR^S�4K�!�v�:�0)���yPTR���M�6��\��RR��RZFb����xv�N�{?��M��_�T?��E	�~�7��]����_+E�ŕ�E���f���ruG�U(z����O�Wٲp�^�VZeq�zeq�����_��n&�/-c�Qe��rY4��bY�%��U��F�u/���&��n��g�T+�Z���_g�_�1��%1�p�e��הY�#`Rv�b,�;d1g�ˤ%Fq��jF
cx�g�#� ���V2rM��#gJ?Bq�l��19 �D���a�Y���Y��Q��@9�R�(f��A�x8뛢������F��Ғ�9���l{���c�Ru�W�s���Yc��њD}d���WM�b��ֺ��5�5��g!��>F�D�aR��ׁ����W�:�.@3w�����������G��4B���?�:1�7ǽ��'64Ύ����4zXZa�,����l��sYX|��o�+v�&���@-�k�qva6�[20;a�[|M�^c�p���O�����a��M���"_ш)a�U��WS�6E`ޔ��X�r#�;BH-X��!�>C��/�ϖ�\�Go¨�v�����2�����Ũ].����6����'�1/.a��X܊m�\� s�o6��Ug�M<�$2��=f�ΐf8����,�Լ�o�:�T�D�ť��U8?7u��? �I�.Х.��sC�~s���X�"���-�e�Z
�Hf�@��Fv���Xb=��prVs�U�~��5���l�w�Z�ED���w���fO��b#�A���گ�>��\T}�<����Fӿ����������ט��?1
9��?728��662�hǀSw"}'�~������f�L�<r3�����G�ל��nwvj�6���x�v������t�ԮF�w����I}����ࢷz�2��J��̇=r^��9�/�=���Zy���5�5'P�my��c��8�v7�j��'���U4�MC�t����sW��+���ljM<�{�J�s\/i��n��G�m�cr�kWS��Gx�}��m(�O������z^#������*���C���8~q/��Wc$P��Y-!�
nhn��CJ.\v��VCB>�>Ĵ���\�%��8E�x Ґ?�r������zZ~=�/��svH|F�r�_v��[qX��=�� ����:n�x=-���a>(9�՝Q	a�w�tp�������Q�7dA>�����.��KdL�9B`������%2$vr�ąȮ8�e/���2���s48}��	6��C��dą#���!�m�~�tp��Ym׳�����JCr�v7��v7��v{��F��?Ǆ�.�n�v7�J�:?��S$b����Iiw�f>�����lV<~H�P%�Nh��=pm�����:�\4SO��!c(���q�{�h���k\�,��8�9��X_����+�/A9`#�xZ?a���Ј���8qk*Nܚ�����U��z�-7���U���*We��tT\�|���ݦ:!��QqU>*��G�U���::^��c5h���su>v������ع�����擆�`�V��[���9,�1*�5Gc�����N�+&���s�5�2�>��"�9O�|�)��e)��8JQX��"���q�aF���6��h�� 7��ȵ�y�d�����9w��1^�R�H�@��������� ќP�      ?      x���ɖ�8��׮w1f����ꞻ�2�Q���N�Z��(�`�-�sX��~Ą����취�e�we���C��^��lP��M������W���?W���tĿk�_�9q|zQ�rI��k��k�O2�K�aU�0�q���0ʈ !�yѶr.�SL׮�mG?dL,0�J/Z��P��O2��t�ׄt#$�P��P)��Y`3|��If���e�~w�!^�_��)O�;�2@K �^T��w,|�Hc<m�q���+cO��M��R��`X��j���^���eD)OF�+�h��p�N-L�i���Th��5�uU��-0ૅ2��(3싷�0���?.2b/OD���zz�h����,�W�6/F�XX���I�I����&`uU��f��i#2�^�� ��Y��h��4�fy7�^�8>�2�Hg���������n��.��v�
*�J�&:���*#���-����������o`@���kO�@I��6KH�F��� &[� ���Z�^4�)���fXFju0g���߼����`ז�V�P�����>���}��V�Fq4<���D�����p �" �l����c����| ��/*UN��j����:�@�Up�fɍ��F@F�5�|W�@yts��D�?5�����t��2�����?~u?߫�~^矟m���K����ou�K{�}Q�ūJ��rx
��j�C���*h�]�w���n��/�3���ꠑ�������F(�Ѻ]����3�D'����w��7��4l1D2��u�-�V7��.��?TM�T�H��?>����6�����`�2������Y��B��r&ɱ�\��?����cpY��8��fw ���*(W�����P��r��1I����U�v9�E�y^�C�
�Vcq��E,tXU =�KXA��fd�1(k7�n]"�e�G����1Fˣ�Z���s``� 2tK�����2νf��&Z����F��d����*�D�}�Y�O2FHJ��-Lũ��C��Q�X]�TgF�Τ=����Wx&8�9�&�>p62����Bdك�L�dƙ����.S��(p�,��d�>�_rT�f<OkU~��߿Ȁ26#^A��k96���te\��5���$(k��a��F���*�����"2�b���%�l�Ap�9l1��H�b���1&㗓�^1_��~�����1��ZF�濃�����xLH8�G��~\'H����K(H�5�SM�9����o�,4�&�5z�k^��a�^�2�V� ��@�j9�h1]Gyxi��"'���L��	��cBD7j9f�Nӵm���ʐ���zZK�x/@�-��u�P��,�1��|&k'#�$�X����ѓ��^>QHA	�b9�������G/d�=F�b�������&	�(�`[m�sN_M��y{�IB6�	��A&�׽v�� OY�I�G#���l����AR��d4�)�]I��4es1�u�$$��r_W�suaB����|pҒ`?#� ��/��|В�O�i��p�.t������
h!���b��pj{�L%j(��K	���
�d��R��lbM�(�8X	Q�#���Tk�@�����X���iU�O*�]��8�D-
�z�������$DaZG�/׬�Pf�:�G��	n�c����Hq/�#NH-
�y��S��8����w�dL�PH�"F�T���.���g�럍3��xu)Pf@!R�T�����R��)#��8�i1�RӽʌR�̨�<ʑ�|�\�qN��R�4�� ���p�����G	`T�Q$��96����!�j���5��cJ�2�ƪ��q�'�������j%�  �9��z,�+bT)U&X���"���i�v~7֨R���"�[r�0�i|M8��O%�M!������6m+j�(Q�Ѓ��&ǡS��v����+�5���IB�����}����wX�˕��X�\�f���䊑(&�!��Nl�<ϧY�-�ng�׻@����]�-(5a(ij�h
c;C�{:�4��9A,������㵑�D!�G�^YS/�Oؐ/�iA��JB6�5FU�W��a%@Pe�d���! ��Q&�+�{\ϡB
�#\d1hA�5zhdu>���Tf��!{]�]�������0�G�CG*{��`3��[j����5������t����k*yI�^�X6T"�\+1��;30��d����]�%�2�UTBFdq2>_�'d\��W*�0���ޭby�w̚9�!i.'Q�}h���K,��X�A�aΐ�,g��/ ��1�`9	���_Ԩ|�T���j�����H�`1DЪ�\ʠ��֓�(��� ����a���?��E�#y�e0@x�!�i�Mr���S�Ѽ!���v]Ӿv37>zE�	+n����%i`��g8LawC͡1z��|0/�O���������ބ=$���*��H,�-eD�RCEig�9'�����Je��� ��Vv9b�(�,���L�x/�l.Do��6֕���`s�9�aV۽��<��$�N�G� ��vѬ ���#H�?9�o��<� Ǯ�3��a,s0���t�f�i���Rz<�b�ȷB�������G��s��o%=p�m�F�v�Cv1�	]���b�֜Ԗ��C;���ʣ�Y�>8tY�2������,fm0}͞K0�ט����hp�:O	]`��L��,��[��u>��u@��c�F#J�tv�\��|A��0l�&^�J��/A W���3�m�(��v)�b2]w��oT���n%ޚ��ޚ��`u�/�GjÒ��R�Ҹ��������� �ZBu���H'��Fv+F]2������&pX�������&�0��r��Mj������� L���D�V~��'j����ޅ�]{���^d��8��U���Fr��c<ث��)5�V(�B��{�@n�
���2�KM���p�o�3.�"�b6Q{��g{\���Y�Ƞf����0�ϰ��=��
e��,T6��+.�x�_cw�т���ܕ�bWG��;�G!
�E�A1{�j<�pO���-
��H{�B��+>���0��N�LT\SwXT�47�H�:`���)-s���w�>c�Ml���E��4���Fn3B3��wXqJۜrd��,�ր�t��
��oQZeFtX���<�Ǒ�N��@mz��c{�&�Y���ފ�1���ZZ/ �r�;`�"]-8�H�M�$X-��� O~���KJ�y,J٨l��㴄�����pf���EA�V??;+� � \���9	�肚�{���/p��k6��:.7�#	n��+c�������mvw\,p[�0�	��q�+�,�1U?޵�q�Q �9ԕ�]وeW"�R�D�T��U��o��K+/��Q�Ǜ�H`H�oېV�Rߑ����Jk�N4��o��P*:f�����-D���u5���2��,�G���ں�l}̜R�̡�͵mXH
���ny|��4�Ε;o.���0�+� X,�b��r#g�9P{�r�(Q/��εO�&2�5<g&=�vjt�a�^�Ȩ�i,�����X�(C�_����+ֽ{���;\_�J���"�j�Q&X�.xѢ6��La���Ӑn��~�${�"D�X) �������`&{�BL`��;p�@K)�:�tm��e�U/,�Ϭ{��q�p!T�T��!߇ҭ}'b���+�4�ah�y��P0�#��\²��v~�ui�AV{��|5��G�h���%G���,�7$Wo2��(����\�����������?2���_�4�K�UF��G��d\�L���"�c��kZЉDKaFە	�Ht�o�䇺=�wL�c��`R�a>�I���d0�h����=�S}�L��ڦ��O������Yf�]�m[|r���=0�)\�
��M�1�	��+t\`ط����s��=%�v ��c1�
g%&h�����| E  �s"���IXqxĈ�p^�E�C��W� ��ǘ�>9�R��5�	�ťf4�30�v���ތ�)�s*bM�ӣ�zǕ�'��d)^�Ζ�'�S�Fxnz͸R>�mi�a1�N�Dy�|G��S]�/�"!�B�嵳*m8�<eV���C2��J�΍�5ZcS?���p�q��Da� �ɽ���W���k���Lz��q�8B)����[>��%Wc�����J�'��*L��gꡝ��\���˰��o֞��+�@ʕPl����;�<)W2�2�Q��q� ���ԣՐ�<��XBT��u©��<FMN??����x����O�n*��y[��g�?9.K�ŧg�?ܫo�n��*�G���O����A��E U<��?�g�3".r������Y	�UA��Ӄ�t�s"Πgw�VW8/�+�?�V� �p��D��좈�x���#9PX!���^��y+�im��ء#S�
h4��6e"noߑ�#�(s�$���H?��A=@���:���0*Ƨg'��\�����(z�v��Z�N=�&��	��C�N�X��U̛���m�P&�(�։b��8�> ����U�FS�=P0�)�����9�u�����C��g;8L���y�:wצ{-��2���	V/�m��k_}�ʈM��+�?-���տ�>vἭO(����@/�O����Ԋ�r^��$W��AYzE+��;�l̊2��^��5n4�*	^�D@�.�C�=���ö���Db�eH���N���iܴ�Id8z7�.5���0S���}Zڐzؑ/�v��f{}yC�k5������_���+�FN��4��z��L���`�'�@�x[	���d��@�"_݂�{�՟N&8�9Ɠ��9x�@�6��â��dB@`k��bI��څO��V��vhS�� }� {�?�=o�=^&��u�j%��Lm��簽_t��������Qj�Y�І�؉�Ӎ|���r�X���v��X�RԊ��;|�;a'ʈs���Q��h�a'J&D��5o�p'�DI�;���7w��w�N���Q�����믿�0tі      �   �  x���k#7�?��
a�1�q^�S���QJ��p�A�zǫY˚��!�{g7�����Wz4%ƏՎf��O#�� IU�'��^�E��B�J��|g��Rf�ޔ��_��������yK&�����������l���r"~�n9hɶƉ�Ds4�P҉����Z�qjW�����xq^�vO�z2���z%=\�H2~�oh�*��i|����ࢱ�����g�6��k)���e��N���]aA_vQ	�0�`-خ��_���R-ͼ���B# ~c(r�p_��#��-iA���3�Ki3�I,A���HAH�	0.ؕ@ɊMŒLv����7
����K�Z��*�X��c
Z�5T���`�Ǻ�)���+A^�uM��UR�jh�ʻ��UQ���(L���Z'���	�:/��1Rĵ�@� ��Y��s/����	(���%��'�p%<�k&x�05{���ͥ�?�r-n�ؐ,!u�D\9Ig� ��a�0�Hϟ��|��3<J��1H*�Ղ�~t6����
C�&UE�r����q��4>5x��'�͒���>��l���h_`6U�y�k�r�@{���WE�2um�EĞ(���2V<I0�*0?#%���\�Dy_��~!Kדe�ˉz���^�~��qz:�Io,�������w�y���PZo�)�#�k��x��^��[7�6�2��RBgh8��j�)���F������)8Ǳ��H9`!�������Di�O�J��W����]sXN){�l�_*����<�גy+9d�)��Gk4T��,��{*���]R*�o��ǐo��g1��Y�ϊ��Oޯ2y��(�8������'mS�oNһ]���c����Gq~�LesF�a�\��Q}�V���;�H�j����7���N�!R^��wCr�HHJ��D�����O7TXP�Q᎙�s�������      ;   �  x�u��n1���O� ���oH QTQ���mؖ��n��<?sLh&뉚��N79��cۙ`���·��n~������CZ�`𷀑Q\��0-a��v�ßq:�>��u=W^ԅk���x>J�$	� �����a���E�"Q'����uu�u:���v��n;�n��4����[����Q��nj9a9�G���M"<'�D��E�K�L:�e�e��7Yv�
עK�r-�עK�s-��A�^Ww=ֿ��RC����46�g�ZLi�:Z��XGǴ��虶�ML�Ɏ�i3ډ'��}?���4<�O��.yp�r�����[��S���"_���~��y�w��KZ@iA�K�@�zд��F������l�+"
:	E8E<=�t,�%6���v|s5�G��ޚ�t]t��!�"A�� 1]y��|�K�n>�d��Y��s� 2ͅחd��7u_;�.@$�D � D���m�Joꞹ��	�������	��������m�������!��0:̻�+dp�,�g����d=u�٩�gq(Ը�v�vu Ο�&�?��.7fx�E3S������ϼ������Z���u��>��Ϧ�N�u.�]�cC��ŗz�W8^.)�|P8v��r��4��Gvc5C1AP�A�{��X (�����r�[�k����-%BQ�9��(Μ�Pk��LLA;@|jb ���&��8@|\b .���V���vu���<�9��)�͏�_}��gv�á֣��gM�/BS|m�������q���a������T�!yUJ�H�2��J���IR�$���.�y�G���竄/�y�M����E͘&%H��I7���H�y�e����U��n��u#�$����+Y��Ϸ]����^      M      x������ � �      �      x�3�,��/J����� �"      �   '   x�3�,�M�̱4��tH����s9M�--�͸b���� �7�      �   |   x�λ �Z���'�vI�������:d��FT.��$v3��$��V��K.���C��X�a���R}v�6m8;���.�i"\﹂�ߞ��eP�&���*ꢍ����@�?P:��9�8n+�      �      x������ � �      �   �  x��MO�0�����#-I
�ā���	i��I&�S���#]/⿯�vE���R�X��ߙ��q�1J3�8s1�n�p1*�
�,�.�i2L'�t~y5O�Q�$?�8A�&��U�M�[�Pj�MZ47c������gϒ���|q�[���yL4���B���\VJ��W��mh-H��P3bp �qE�TN�� �_w���&���
w`Cbf�6�m���<�[���1���lxuj���W78�vO�)T��ُ��w������P�5�]�� B�1����4No��a*^+Y�5�1�~`���]s!p�U���)1�*@��E5���In}T*��P�	�aeh��Q�%n�p$���M5#��)'ʿ��>|���`��XB���<7���q#������U-	����G��ja�{��s���kF�ekV��˕�Y��w�5�wǠ�A)z��?� ���1�l��#&ӎ��;�Nt�����D:�okT�%��/�-,G/�,'X>,��d��Ѽ�E�^�w�����,�Ԍ���Fq�<wG��d>~�Rs@)K���ԣe�>���$2��.�P��HC�4lt�]Mg��rj/���d�@J�Uh/<���� .�}��T|6M&~�ȥAnɴ����6e�.b�AF-�"���kU}�N�9V�{���	�~�'���ز�%�����h�T]$W�$�_�6�Q�k�[�)��VrMR�6q���_���`0�)i         &   x�3����M�2��OK�LN�2��/�H-*����� }��      
   )   x�3��LI��2�t,M���2���SH-*������� �E�         �  x�U�ۊ�0����ȥcY�Ʌ�P\��&��6dY(�,K��8$���w�I!;�b���Q��P���Agc���qH
�ni̠~���nF� ysƙ�����@��}�$������䇩n�k;� �z� ����@ ��T�`,�XϏ�P�}K��y�Kݵ�c;���?�Ho��Pt�ORPn;�}�N�@���)�����>�u@8�0����7�`��ey���_�&���O|0&����1N�EZ�	��7���%_���k(��u=R�V���������t��K���|�HpgS�ˑ����\��BVJ����!6��iV��ReR�HME�)	�a�!B!���"�H1�������YY]��̰��2Mj�a¯K��-��            x������ � �      ]   �  x��Xm��H������n�Ð�U��SsI�ݹIU
y��AyѰ���Ya���UY�,��g����l{"mG��'�*�&�)��ӛW��0�w��^��] ��4�:�=��w� ��f�߄�fl}�{<�/4[����l�)�v�b���q�;�_p��s�H����+����ĉWo��ǵ�b�^�ֵ��=���
�3�a��k �m@m@$���E��S��C�3��d�W@�g�(�+�T�J���`�|��^�v�� OZ� �g�rK�����,��,-s�y�
$i��ܨ��2,ʰ1��q4COG-�*U�at��C�Gl��q8/��I�#��s�Z��.3��i�x!y������ b�׷B=XFf�k|�)P�0�{����,e,O�#&�����;P��"'4D�
L�ս��G�c$�VJ��� [�c �d����H?�ץH?�Z��^�P`�z�D���E���2�bM�vC �zo��10!�6C������L:dC2r �G��	��f�I��r�c���ئ����oe���l�.������K4���v�r�������NM�pA�w�%b�?��~QW��ַ���t���-u�e�9~�e\��wJr��x���V�]h��L��]Z�!Z�#Z�X񚋳h�G�9��/8F�;ǆ�� �.129�c���Ȃ�>4z�2�u��k%���Js� �+��/��d'��R�uUG��'�=��xٓ�5`��E�y���a�sKX@�,�ʳr��­%0A�Z�I�H��&L���E�d&}�����QA�Hlms�i��q!y5f��^��
?�@T1�K�A^�%\���Dw��e-#{�.�<�
���ɍ��z& gl=;7���I(DJH��A
a��P���Q��0}^X1308^�ȁ��В"�;Qm�@��/O\��;�X����2�/<�_''�
�
:�&���j�(��a��6TVŪ��&�� �	�<� � b�Bp�ȝ�>�^A�	+c����A^p�x6F���wԪD�`�t��$���U0��t�@�VCKQ��ߒL��5e��,X��O�/2j��*��#`>��S��Z�h]�(��i����.�������3��q�EMx��⸘����5���"�}]��{�%JǕG�h���]eM��1ST�1�b��ơ�/6��2u��CK���⢉�ց��ؓ��D$�s�f^�"�d��;W������o���X�)����6,/�����d�*@[�0�D����2�W7- ��잡��ڔ��[XD�k�J�p/]��%2�~du��i�����K-���q��ɪ2���J�Q�*�*����Z :�ۧse\xطC��i�X�d��*\D�J6X�&�°��n6~.�C�W�<1����H�ٽ�>� �3�o[���F������A��n���)x��,����$�"�<� ��z>^��� <w��           x�}��n!Eמ��Ti^$��h���L �¨���H}*!��s/�e����ǟ��n ��vkфِ5B�`+��я(�u 8%(�0�z-��(D�3�n��Rf#��T�'��-\V�F)^��G����'��l�0��1�Z�)k��h]٨��;�[�P��4�r���x�D�\�p�V8�3�@�5�C������9E҄��1kߢw�i�s���1�n�/Q{���C�4>�p�u�x��      K      x������ � �      �      x������ � �      )      x������ � �      .      x������ � �      �      x�3�,�,�������� J�      �   D   x�3��MLɨLT(JLI-��4�2�J�J,.�H��9�r�2S9��L8�R�"󋲁�=... P0      C      x������ � �      G     x�M��N�0Eg�+���N��0��{�e���u�JQ��[۩)�I��u]���u� �����v_o��:eC�)'�_΀�pA��\X�[� J}�:x�9��h |� �ɿJp^F�X�O��+PJ /l)�o(��+
�Q>�D��˱]Y2�/=��.��dA�)d�r�2i�2i�A*�>H���p����f�pq�p��yؕ�*�-8w߰�8|g��2��pGs����Oˎ��-�.�qq�1S���c�St�zj��������F�      �   �   x�u�Qk�0��/�"�Ѭ뤏��6Eź�"����U�$����9��޾����j��~�����k��M���[�v�&���8�}�L�
����ܡ'kdÏ��w��(�A�38��2����
~��t�!��MÕm�4Ka�F��?
yOC�)�(h��
΅�_�=�J#�/�{���tL��y.�"In��N���-c��nn�          �   x�m�OO!��̧�h
�?�k�hbMcՓ�閮��i����z ۮ�y?��(���ǆ,��[Ьѯl-�n��k�!�Í�,�H�0eh��X���EǢX�0�����@)a�G���푽@i��������0z�����7����d��բ��Q�RG��nµ�,\���b��k����,��ܜO'��ZF�t�!��'��§�e�Sڕ�LC:vXۘ(��=���K��b��,�c����[ܗw      W   �   x�}��N�0E�7_� ���- uA�b3I��R�l����Z��n����L�����|�x���v�s���8;6���@-T��~˾�L�44�O�D��B��B��0�3L��!����֐9f����R�O�ٙ�&Y`�i�,�Гs�bi�%x%o��9͌M��H���KHCFW�2MQ^a�{���6��,8T�D�I2v,���(=_�x7���M�vY�7�i�J      O   �   x��Q�0 ���0����hL<�?P�,�-��?�WS�B\Q&���=@i�qȬ�滟�ΐ���1̧N&.��N$&0�뾹�{Ƥ�,��!�G�՚6+-]e�ǖ[Z�բw��,�&�1HP���}���u�'?/9�?�/�      3      x������ � �            x������ � �      e   q  x�}�Qo�0ǟ�Ì�s�G�D�����sB�x5����blQȞ��w��w��w�&0oCv+�����#THNM�}]����HX�+�	,x�R�rV��P�{&���z�\φ�������w>�ވ��ח#{1f#��y����@��P��z
��z�G�'�����}�7)J���`m�2wLd�$���H�6i�DxdITFۢP�y�{�K�mg>��y7te���B�{87����%�oW�v���ak��&�	޵q���G�-�ة��U�@���́�����~��Y�,��7'p�k�]Te�\aB�G]���+{-�+d�FՇ���<	�b���ޅ��`}9Q���u� �CH�      +      x������ � �      *      x������ � �      �      x������ � �      �      x������ � �      �   @  x�U���� ��3.&�$��T���xl��frX|�b,�5o���]^)*�J�RVZ�v���u�aǀɠ������������-�-�
�-�-�-�Fo�F#��bhm���6�fo�F�m�M�)�6�&�D�h�M&Z�e��I��yDK�DK��������B[2�hm�m����6�F�hm˶�m�����ۉ�&��G;���΄=9��'�v��ɻ�z~��Y�%�-��]��GK���z�]��]��˺wi��"��6�V�v�����֌�Iјk��+]cR6&mcR7&}cR8v��;�#Ӄ�A.�����=�B      �      x��TM��0='�b���R��
q��j�n���8��6�q�q���^'����r�����덋OY1�VZ�ټ^�9Oz�D�����������^� ����Ym"*�,U>l��D#bg�-Rv>�%"7R"s�8�B���txw^�c�c_���u��w"�ي��)]���5ҳ����Ϋ��x�Y�q��$��W�`�K>�3t̥r-iH�ډ��m�N�Mv�� ��p��&W�yRRϠ�~
����ݝu��V%&���\w��ڇؐ�mIz"��C4���}<-,�V�F���*O��SgYP�n66Xd���S� ��
F�Tq�E����)��$��:��'v����t�(��a� �[D���l{ԋLL��fy��2���(�Q�*���$r�j�M��Lp�	^��^����̾��EF+m̸C���}N�Q)ź�ʨQ��oL���ćO�KR���U�&�LF��ŏ�:Nܨ��\�ç^��<�� �J�      =   4   x�3�4��(MO��K�M�K�I�473� !3sNC�J��������L�=... 1Y�      2      x������ � �      1      x������ � �      �      x�}\K�4=n\�
�B|�Q��V��3����o��꩒	��7eI!2����^�Å�o*�S���E��>�������������������/��Q�Uʋ�*� J�(���F �?$_0j�^�gviE���	f����`������K� X�`���K쒎`��� c��@�m,ɔ�X����F�~��O/�sXk�`���0.�t�F��o���^B~n�prƩӄ��;�9O��sz����s���{��;�nV�ߚ��5�ӗ��Ԇp�r?���3���^D���@��E���y�l\V͘��~2��c�8�k�S����N|q��W��N|	��ڮ��N|	\P�o;2�|��D�+�sw�RN��W�.A���%�j���ʃ[�A����GܣQ��9�b=7Ղ��j�T��~����`�2	�g��"��k(��v�����t���c����B���~3Z�eСhY���<q���2A_���(n,tc����]Ґ����������9��+�y2a�܌)tCj�j5��<q���Q]a=�lVV���~d��UN����j�J����S�6~�&i��ЖX9�����	���,�a�|��Ж��WK-F��ez����Aci+K&�����
����ɫt�I����#Mc'M���u�*�Z�9������A{^�B�I�".�+t�uc��o+6h:����č�rqO��* ��V6C޸��d�����j;,����_�w�x"��������S�*�m��qK�|�]��Y����Y�x+�ߦFz�K0�i�L{T�Ț4>�6z�j��&G�ؒ^��͚d�䊝��m,Ѹ\���[R7.k��3�o.�~���
��F�	�As���+]�ޮ������q���0tZa��X�J7C0���6\�**�. �J�^�N��ɄIfE�uvZ��fB~�N���n���37��af�:���Q��ٗC�����{)�����|�����2E���)�vYcS(#]Vw<���Byä8����)#���Q'x}�����K�������%������W[u,S*�̟4)c5)�
E�!|�i�����<2np'��4�q��@�Le��ą)��]Y�ύ��tY�����e���SY��S��X�f���wG��|�����2#�^Ra�HecK�<X*����F����A2T6�L�E�)8J_,�^�d2���j�G���a<�Ɨ�:`��jи�G��V��m����`�"�[$�8��e�F\��7�Ɨącpň�-m|i�����{:�o���%#��B3hD��`K"(l����-g��g���>����b ��'�q=ߗ��=��ތ'��%�u_�b_��a�qg$;�V���^MF��v���"��o|I���O�!3L��%3Tn�C�2䋔�����.��v����y�,D ��Ix]o��=�U��)G�8?�*�d��č����ؒ�忩��H�V\ ��/��%t��8�����#�;�o�o1�/�0q�<���J��|��e�).��|����r징�8��2\�@^+��oD,�v���ƭ����AaF��%p5��ǽĭ|��G�)��0�!]��5�|(��V���Lu�\��߷ڗ���}6��ԕ/7�������-����9Q\�]�2q�#�{�K�ڗ�M���	[���Q�t6�/��e�x�XG�Ɨ��ڥ�l���Y���b_jꗬ|�m��/���A�b_j��u<���YW�r�̏����z�K?܏��z�KVM|_�z'�Ԍ�B_��'�d���Q������8���ė��_s�	Ͻ����Q��6�'�$N�N������Y�8�m'���6�A�N|i��u.�P;�%q���qq;�E!����H�ėv�PpN�ډ/-�Ѓ8��N|iE.���8�K�/�N|i�ms�°#�ډ/-��n_��g��}���3_8��AA�����q�~����+��7���7F��Ɨ����`{�7��q��*��Ɨ���N`R���ƹ���NA}����Эm��06�L\&�ֻc�K�f��6��q��4,9���2q���
�s��"�+�Wƙ/*q�*֟���Gw4؊I������ߙ/������A�̗Y�W�_�e�����v���ή������/\V�.�Y���>.+_$�}#�s;(��%p#턯ǰ��3�k��Ӓ���:�K�w~��y����������p��?���}�B��̿��
.c�Eq>�ӯ�}�����"��V��}v�q��x�?1�W\������G�ĵw��~��0�^�P���a��ъ{�����i%̍�8x�i%e�7>�@�������F�wf>4q���^\�Ӣ�6k�XIr4㞀��W��g�(ӳ��!Ѥ��Z�(3q�!'ë�����
ˆ̫��q=C(���1�V�f"���7�$�Z�n6f�LO#*�;W�/܌L��]U�Q)�C�g_��[*�Q� ��0X��"�v��n9��1�IXt�N��j.!����w�x��'�����`�ɲ��K�3dFL�����7q���1���X�� V�Ra�X���y�T+�4q98h�u54�9��q�ɦ��(Mw��`+*�jhn\�����������8QǷ�A��H`혵��Ӣ6�0W��1���"���O�3���8�T��5M�eO��f��0��q
cQ`��m�2��`���Y�9ȤsP�_�V+�Sw\}g�`)!����3�;q�D�H�8A��fdr�,��[QؖǶQf�F���U�U�L\��%���ucL����5�e�g���b���G��<����uDr[h��_�x������F���ac���׍072ψ�z"L�����o��D�M%{�	��ۘ	� �c��N��,Gh ��pn��y�j�mN���v'�O��mNi�������$.$�&��쀫�e̗�9�U�ܸ�	tX �fdK���|1,�q[��i�Y��0a�m�0R���C���8݉s��X3���ܸ�x($r��zY��@��ľFK3�㲰�9��Ǿ��e!8��aᙻ-���e��D*���ܸ�;��9�|���2�u_̍��~+��X��iv�����(_�q�c5����m�~��7�����1E"����0��px��T���P��n�aCgŅf�y�n�a�%Ƶ�;����sp,�G��%:r&Wtyl��R�ZR�e)+.�k,g���K�.V��)|ƥ5���Z�/��\��q�x�[���g���FIR6��qQ�}�sU�9'K��7���D���/r�8��ņ^�l�"��4�4;�Zn[O@���A`���던��u6hB峧��-0�w�u\/z4C���Dv�Q-��	�/W��kك
�9�v^��tI.����HP�b�q^odO!�Z��^H��P�>Y���ѻ
k{�'S3#֮�y�'S3��s������^����^a[����K�%��Ɨ|�H�����m)'�2���#-�y����P2	o&{&)ǐK����#�L���0�*B�w�q�qMd����̇��c��/��*V"_�;E\.��Id�/�4��O�L6��.)E�%�l�ݡ���^6��#����\���Xd�K�B19?��=�%d�F(G�.�f_��|�Kz�d���=�6��`������U(9W	�������%J{���
f�G��<�ꉮ|�9ˤ�x��]�2'~5+
TW�М5��{x5EW�м�/?`;h+_7����!���~�kd�*V���%���=T�u[���zD�jp$SL��Yˏ$ou����V\δd{�����&N��0?m����dj
�,[�2{�%gZp������/���P"��W`�lf�!a"�;6 gr�<)��1����3�K�cw�>���Z��sIe^`�F�Ƙ~Oa���+M�jaf6:E�C7�TW0�.Pn)Y�	"Ҽ� ���C�qZ��8����ʏ���t5�6�Qـ5;G�U��0��ry�{����d[P���
�y��͚_\�8�t���f�H�C��z\�J �  "����-�x����G�	8B1?Dm��8 -K�����K��գW??"K�WR�Z�����|�E1).>�9�.\�ѐ���]W����G7P��I�}���8�I��1��m־/u@���1Tni������~|!B%� ے�}�\�~Ȃ�X��~�n�|�Ņņ{�|�q���-+_n��_q�j�&�]m��c���)�$���*c�ˍ�0O��m|y�G�Y�8�%ڨ��`^�_$��gPj9�Es�7��Cp�ė�E{/T@ZN|�{�`(�e�K���+r��G��Ɨ��]����/�}
Ib�vWK��t ��<����0���	������|6�j�3q-�[Ì��1�u�Xh�w*m����&��U�3n�q1�7PicL63���h�ˈ�1fd�/�+BJ+cb`�d�^}PZ-g�1,�K�qDZ	3��q�dy�V�i��n�CP#�K'`�f7�J�G`>�`:Mye̍���$�+cf��9�ҭ�2�����d��W��GWg!���4yc��}�т�O�7����k}xJycLjP��0���c��hu�X�4�ja~��x��2���̧W�S�F����/s����b���E��D?f*+_$}Y��w�uI���y�k�Q;�$��0��%ݫQ_�;���\ҽ��/G$tI�&nX� �uI�Ng�Q<�Ēz�
,_��O�o`-!�쪰�_�|���ǯ�ʎ���Δ�n��w@�Q��af�\�Q񓶺f�r�A���F��s�o10"T7�M��_��WՕ04��5�wx6[m%�[�Jx�H�|��y�H���a���z_\�0�/��|����-=��P[��3�j+_��٭�;��-��/�1�:�	K;[�2�-�ʆ���V��t����¼��ƗL�r6LRh���o����I�n|ɷ&BP�=���_�{HŮ����믿��y�      [      x���I�-����]~�y�C��Ve������� ���Y���| !@�'����?1�ʿ�|��*��V���?�����%eW�+V_g����颐|�����Y_=_��;Q��Z_=�G���1�Bx��G�_kV�_��S�P���B3�j{��c�^s��E��+�Wɯ�|c�l1���$z���q�����|��یI������9��Zt�������km��r���}_Cc[?ӭ�V�}	so]᧭�x&���G�0.��6ć>ּ&�X�L~����"3>�+EߧPl�+��J��|_�St�V2�����Fj��J��<�n8�7Ć�hx���W���u`Y�����+�k5��Z[ί'9��O��E��8|��W��8V�7U}�k�]��A���}�!�p�	/����_��MF_����d%�PC����٪=\m��h5�v!J5��-}/:�h��DB5�ӹ�v�P�z�0���+��/tI*��ZZ������=ԭ�Nj��r�1��os�R�v?���dx���R%��F���׵��B�)����K��(E.�UQ�Q[�ZNw@��8�%-:PS|1�X��LfJ~��?T
m)��C���Ew%�����hj��(ZTZzǿ\�=q)�^��=�u��.Be%��{�K���Q��i��ޟ��5ї�N���I�8J���ڰ�V1׳BEt=է��@}�\/
��^��]ܷ����U�ҫT3�#����M�*y��V1׻@erj���;js}Q�E�����S���0j�j���!�0P�=�z��!�E�1��c>PW17������l8�U��-�?sx�>b`݃��O���0
^[([�p4pCz���[��ȷ���!����{��n17��Ai�w��.`sCz���&�[|�sCz.-����*��649����ෘ�����~�g^�[�M�m:���'��U�M�mP�4��jsSz.�����[�M�-PJSY�<�CW17���F�C��_��bnJo�y��v���)�E�Ty�<�W17�����|�4�U�M�-:̓"rIO�w���A��NsU]bz�����"N�<ӈ?b`i���Η��#��Ԁ:�H3����]F��t��3��k��&^R���`�J�XM�*���-y+��'^q�:/����h6p��B�yb��[�n1cЬAap��ԍ�XQ�&������z���+G�o��
1��U�O�:��hV~D����z������)�:k�%���~������ÏX�o`䒪��:b`i���B��u )���~�4Dtr��k�[�Ť�F��d�X�o�մ̧X�X��ȼ�Qhy��b��R�|b�V�佁u��U+Q��NJ1�ֶ�#�sEz잭,!V��!5	cݐb`�m���?!�(gJ��=�(�T���)�yͣ��9hV�^C=<��WV��D�H2�5���+���V����x�(V[Y�����!���;�f�g�����Q������/\�Z��b`M��$?�g�4�Q��v͈Q������F�q�]�:+7u6?����Q���ڽ^
��ƺ!����9�Hiw���W��:Ǯp}Y����b�R�zg�,�hS�k�Ǜ� ���fN�>����XC�,��QC�W������������r��#ȣXQ�,�Xh�
��ͮت���y��Z߬k��Wq�u˘�*p}���N��OU^�����{�\�F��նsu#<U�8��j ��#���\h3����fi}�V�C��] 0���_����𣘋-�����ĵd�X�� I
D.GDOmF@�h�X8���+�f Y9���e�=�x@`(�ߙ5ٰ�#V���U�@�21��f����o���  ����5G.�pA���v�)r��u�&c$����?����w6�x/� ׷ş������QI\�O�r����~����q���/��.��fE
�B�pj�?V�y}-䕪a=�(V�n6Q<Fs��ݮ��6��x�T-��qjG� �(Ŕ�h0�i|Z!���\5��}+�f ��ڜٸ�6Tr���sqFŢ���J���4k�Z�0d����+׸��`�_���
Tq����R��a�i� �dY~;���5k�a9�(��ș��0|�|�U̥��<�D�r���dK�����!��(V,J��(�g��b`�b'�s\R����<,b�oV/)����Ux�:~;{ks)��xSE��WN-i���opӦF��H1��`��D��w�XM�����[��5�ǲ��,k<G1���޼/(���{5p)m�Up�"�)�1�@;)��7�$���*���c����0|��^T�k�GA��Ʊ��-�]i�^�!@����{�����Ľ���Z���|��r��b.-	�v�OTMϥ��J�5iR�SC�b`-a�o9ͳ4�����hk��U�x;\TQ�6��C<�|�|1d�����5����jjHZ̥��B�^$��������;�c�l#�Xuee
j��m�V�XM�he�;�`}.!V�,�7 _e��B��X4O>v�3�b`Mͪ�<Pl:i1����wq�-u�L��X�����g��-V�,��-��b`e͚�	<���b`Ţ�2��#��#V�:�̣�AӨ��ymm ������oG@`J�B���|ݩ�.�m��U<(��?n`5��I]�7��:���>��#���d�׿p�g��]�)�H���\_5PNE�>�� �7��������?������o\?�ƅ݇���p�t�t6d؊ps�KW�x����p91�W]���b�v���������r�3�lu�B��{���T�8N�E�4��^9B��7��&p��^�@���eIk�"��ں���d��?���b`Ū�J����B��oּ��֬��� �7}���?�g��G��Y<[�!�k��t�k�-���;�^/FaH�=��4�bQ�A���h���J���p�6�������X�o�$��XE�"�ْ3�XU�(���b�u�)Vi��b�b{K���y��*�&�X�}��F�a3�Q����q�jM��b`mm�5"��}��Ej1��bUޯ��S B��-�p�Y�|��J1��fu�R4>�km�1�>�@�~+��K�����R:�Ζ���Z���P�D��a�xxk�,�����X�ߠ�bޯ�#\�������q��:ۈ�J��iK1�V��Ї���e)V���t�ۢ���,
}�<�l��xs9m��Z�$X�SqR��Y��1��G1�6Ȯ�\��YB���(�ܕfk�b`�m�:��*�����,)�r���?�.mH1��΢e9>.05c��b`��r�V�/�Mc,*����E	�4c��c{)V�Y��K���H1��2g�x�l>��,�4�����8^��w�N\/p���b�Q>X}�s�u����#��>��i���N�:����P3+�O�XU����#��
�jPm��XE���c[6&��B;k9%1�A�4�$ ��2���	�����i��O#��K1��`q-eAY�C)���Ưk>�����k����5�1NF�����ule�谌�m)V�ɿӗ�^Q���j
Z���OI[y�CǢ�]�8m ��C�y)o�wm��X �	�2ϱӒ��fۉ����t��M�r�:Ԗm��="߿UP(�ۺ��
��&�k�m������ꕵ���L����Z��o��('/� 0�������^�61�GXY����l�Xug]�<g�&nr�Z����#pG�)E-VW,�ݤc�L�$-��2e�4�oȶ�+�-4:���Z��*����<�2�Йq� ׏:�{+�e0���D@`�K	��!L�6!�J��!!�%�֓�XQ�"E�����XI������nk��1�˃2F��S���v��C#��{f��K��U�vEkN��)V.�,c̕�b`����E�Z�q �  b�Z�kj7�n۵��\�A�&��mZ�xb�1=�[��X4��|��#h1��f%��Fx�~���~����fK=�b`I�A��i3ﰍ��X�od>��?�7V1���(���������%��9a�@��%�F���ZT)�J��F�L^��Cǎb`Eͪ�d'~��k�[��od޹�izӸ�����?��7[9���>@@�򕴢6�kT�������p!V�7��w���0�p5��f9�c��)��Y4Q�Ǹ�i1��f{�����S����Ί��˿8��H���\gYئ��X[�����wξ`	1��f�GZZ�k��'g����\�X�3���@��wQ��	V��-Ywdh1�V��xg!�Rh�S4�Xcg���ε��R��:Ի<S���aS�R�A����ùJҀ:K�c�hc���o���~]�:~cƭkm���c��)(�Lb-V�YW`]�O�ч�n�W9��W}ʌ6�@;N��'�ht�����1�kk`�>y�5��Yh1��`�ϱ���G1Wj�Y4��g'[ίk�ϩ�§�ض�i1���9���,��:�X[�]�D��V'��*;�}M�Y�K���v�י̕_��}I1��κB=�n�,�X]�*��TW�m���Ï�(�;�)��OïV����ES�t���}i1WZXY���td�� �%�����G4Юh�BZ���"�F䑆�j1��`%>�g�j<h1��`���\��G�b`��V��h��Td� �֛��
ۤ���,ڈG?���(--�����p�Զ���XS��G�y]��k%G1Wz�,>M����XQ��jq����ڜ��cy���1�Vgp��(�[geI1���;.���Tk?4Pi �z���5Mͩi�������� ���ugD��m�P�b`���ڒ�9јq����ۋ��w闘uޔ6pe}��w��&ȵXQ�*�	e�1��#�Ų����ʂ5�Դj�L�b`��i�7.�����ɧ�a�g�)��Xk��}��e;�J�����k��'��-��>'_iQ��<7i�� ��M}H�6pe��i��O�M���Z�(X�7r��ki1��|1���x�>�O@`k���%Z̶�"-�$_?dA�b�n��b`U�T����o-���v��p�S�" �����{>�?Xk�s��ι�y/}      �      x�3�4�47�43�#�=... *�O      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      U      x�u�K�-+�t[>ٗ/,x�i�-e)��;.r�piڮ��Z�$<��O�'�ߘ�/���!��)=%��9�>-���'N��[P��k���_��O��Y������x�iUb)�����,o��S~bJ�6�������H��9�S/;�>o����p�e��C��������}� q�'ˋ����-�驭L�藸8���Q�[�a�5�,/�IՔ(`���a�'�g���\���Z����P�Z��&����a��$��3�<m����_ÆU|���*�{� �Om�iX~r�����藸8�!����u���q棴,��+���ـ��]E����; ?=�+���;`~ru�!`~���	��o��ˋt}g��K��-�`V\��L�2����$�8g
?�\��Yfl��$�_Ԝ8l��gsf7���*��>�oP����!��S�l��lB�i9�[��ķܖM~�;�i�S�'D�y��R~EyBKj虬a�O�����A���O��+������G�g'>�K���׿��<�TĲي=�,g���F^I��~�ds{��6�}%�3�a���ފ�rw���٫͞I-�.�8���;��M��+��Tq��kx�~�H���Uju��:q�'�w�h A��0�Ќ��~Y%ޕC�A�}�;%y���ϛf�Q��?nAx����(���w@|�,%V�=~����ؼ���9��~�jq=�����o�� �HR�]"q�K�u����_q�8}���ug0�����x��L��y�jM^�w�xb�-k�~���&2��h���8%n�9�JR9�)qsӉ�K��v ����jw`sĉe�\�� �o0����8[����h����O�t�9��à�u4���(h<9��i�K�8��/&��䔸����0��W�]o�G����+=���ns�32��:���0� Ȁ$&��*N��6�9�T$J��An�1���qe�҆o�8��3d$3���z��`�T|�0���3�~<�p�{�?nA��(3��|��/P���n,K�����3��]f�9���@�a��Ŀe��~7V��/��MA�&�U�f�x����;�����G��U�׳�#1�3��	�t�s�#9 =%S�'w@~�;[���9��<��:����������П 3��~<�rd ��x��o��f|7�m(�	�ؚ9��e �v��zW��1��7�� �ՠ֊�M~Ü�����{�Ĝf,�ʣRkE܂9Z�A�׷\/J�W���~�:���+�(C&^!���Xn���e��M,�y�S`����[L����l̦G�&���:�[������j��n�	dT$�ۤeo�2/���]�2�V���u��b�)>E]h܍=��̳�av�
��@�~;�9�Bp9��=h���̦�S�AG�'#$�O{�e��a�*��QH�B$`�0z��l��'`�g��	��{���@���[�#�Zt�ț$r�:en���	���S� J��XFS�)`�]�(��'˔e?���X��D�ac��V�-�\��8E���j,O�C��ҳ����$��iX*�何�
��+�e��E�x+gWf�wV����L��
��rM����?�A�i`��BF�!��iI���e���2Ip�.U7���[I��
`���tNܬ�@�p.�Y�2���)ZC�)sN ���/�}v�}���%BE��8�2+ 0'�y��d�) N͖[@����Ω���W��
P�ǧ�u{U���2]hos�-Ip�.0G;��9��G+*���Ŕy
,�������d�GF��j��%`��*h��h�X���J�+���	��By�2�8����	%�e.�(ÀQf���&���b}��������/�'��AvEH|H궔��$�,��"���s2+`P����Y~�k�Kx_�\C���8g�O;�2?���<m}�2?��
�t	>�Lݞ���ѳ���_K�.�C��s�G�ڔ�	6��L�N�E�TɇH��9PB/X�"�f��6�R;D�`�@�²�(�a�<����Q��n�Tdg{:�����Ng�{��Wz�T%�0М�������Hf�-:?t��ksJKN�[� ��ttI-;en���อxe~�t�AjO�(�:�)`��RU"��р���Pf���J�V�s���X 3Y	W8�
`oF2�s<n�ݧi�X��C�;z�G'�?�O����1�?`I'a���F=S��`����1���S��uTp�j"��� ���KA`~Ki�_���w�t+�=A��5�v��;YL��U�V�@����D�H�,�c@�6�5=�������y��䧥��g��F9�kԱ���<GM��!^
iZ52�W�'  �v�|c�]��H�@6ͯI|pt��\}L��'HIڇq�Y���,1?�c�d87>ٞ�M瀫=c֑\_�^9��#6�{jȝ�	dR����e���/=Y�bH�Ak|���{*2������ǭ��R\ �Hx�O�SL?��Xd�TU�O�k��%��f�e�E_cy
Ȧ��)/�������L�e��.�E|�숍e�9{��qe�>�Ȟϐ��)`�e(��5�!�S�������5��W��� �,H�`<���U,��6��i��*�ݔy
� 5�
��,��A��2B��z�)�@���q�!�s9�M%��s���r* ���K��F�;gKl@j��Ƙ��)����Sc����/�|N��;�tpC�A�}���:Ǡhb%SR\���f�fE>�x퉷
I��Hk�-�T(���@�v�j�7��?b���1Q�@��H���h���3�i�����m��wǖC��n��V�J�J֊�K3U/)LG�}k뉩�K%���� ��Fǲ�!�|�9�[����2b�TI�T䠛�b�/��ë�J��Ң},�}6��R�=k�ΖI:M(1G�rN ���*���cN���М�g,^ϏvMXS	�Ȁ:f�G��iN���^
�Յy���$R8 >1��{�n��]���<f�I������T5|�B�\ �s�����,�@���}��S�i�����z�%�_z*0�rٹ)�͏� k�I�q1���YD�*��b����}���	O�s
����q�S� ?HZ��R����%�X��&������q��SY�ǯ�����Uץ�w�M��X�49Î�����6Y<�.�B3{��������K�W���A�]���2��o����.��k�H�B�ǩj�*�{(k�
�/�yn�"�=q3��%�@�U�����d��ƒ_��8��dW��*��s�^�	�8oeP�j�^c��}kN���'2R���3��mxe~̩?fI��~�'p@�CyZ�߱�c�Xx��x�~��=��	��-p@]ў���� ���◹�H�4���"$�Y�p����]z����+��9��~?-	���a�<���-u?2&��"$�@W��2"1h\D��:�9]��wT�$�@Ǿ��g"vIן��g�ldS�)  �lك��-N�[p�:���nՔy
 @B\j4S�) ����Y��v�'X��즑/q��S�A����ۓet�^�!l��JY7|K;�^j�H��c�R-�g�	N �]=k*�қ��| "�1ٌ�ob�XP���s���>��sB.�u��Xn9��	�����X�@r��O۽2?�q�0�;|�H#X��i=ҽ5��8�,ؠ��(���f,�`�p`3�{C?[bOL�8����O3@ء$��[9��d��t8I��)cy
�e��I���U�g�k��8`v��R�p� �".���x6��0��<�߆���}�ŖIV܋QE�Y����s�_�;χ" ۡ�l�ay��X���)'R�歜�AE`o�@FAR\�b�u�ͩ��x����+P��؄��i�8!�n�����Qe�8��    Xn���JZ���Xn��t�s�4�"���#��>>��)�l�pQR�h0"Q���0?y��{�"�v�91��`���,�@��4���f�j��M�Qf�s�$�mj�W����#�\
6�;ƈO3��Ŵv�C@����u��l%D�}���߶@+��D�ɹ�RG�@!�MN�2�̑/��v�CY�9��e&����6`#�U�w�e-���K��+����[y#���/GB&�/��
 '��c�Ґ؇�,���أ����\���5|���]�	tG@�K쳮?��z�w�� ��̐+` Ҝ���x?-	�%�T�W浾�i�q�D����0({`�Q�)�X0��ز�J���d,9g�Z���8 k�%�}֮���B
��u��Uƒ�>�>kW� �8����)B\��$Pft�v �Y�2��M�����z>��G���z>�pL�c�Z=ڂ���$#�a'
q26��zR�Ƈ.�!>U����Y\�m3>t	�9��:d�HʹC���v���/ �6�d9ǒ��ǆ�Ծg���
�m�.�
V$2r�┹���̙���H��2O����Pf3e����~���X����+`ХZC���%90����`����'�A�n
O=�5DH�_���i/��3d'IB�;�0���"K�g��������xe~�9�G�թ�-`04���Ҝ���M@��K����5���(z&>�C����4'G��% P�K�F�VFt,��G�d�%54�y�S��9P��gi俩�+p@��m�Y�ǟr�|��x����~�5�of�x5�l�efZ�
�e$p�$�>{4�C�C1(!ì#��WC��U�7�7x5�	,@� o���?�Z�.�0|��	ߟf��7BK�u}���jI���7���1��թ�-p�г�sN���X0�mB~��[� ��.�J~�W�'p�2K��<�fc��p�/;�:����e����h(��e��U���<m�Ҡ�`N�ފ*~�.��f�ˡ:~����Is����|�/rv��́o���ڡ�Pd9'�
���w~��	Q�ך쇺 G��2=����[bF:P�s����?� ف-5�<����9�Cj��_�X��
���e.��dٛ���X��) �� <�\0�f��l�p
��8�!��O�}�dǍ�и-IpY@����^��hB��p���-��d�/�L�!8@��E,ɇH���I�r���.�$�8���xZX0��؅�S��!8 >�fj��.�ʓe�fN�G�*�@�G�6����v	N���g^%���˖��Y��l|����m��T��.�潥�8@�/�w�e�`��/B��|�<��.����X���s�#K,�@hr3e�� {�j���l��n�� ⷙ"�,`�IR�r� ��<-E�Yp��432b,єy
N��sp��Lly	6@�١uk`.���@AH[82E�Y���2�ʥ:en����ݗ�����(��(S�	'P��dy���^_6\�u�\�_�0�����ygq������'p@[�'E�Y��9 LR��[�u�7�!ׇ>�s��3��7�����	hMj���'pAG{[Ǐ2U���X$y����s	�t#cn�+K����a�����V����]<��5�4��-��!8���,ˏR���r�[�QC�����w"W���Pf�Q�
,�3�Z����8`:�e�m�>�����v�8 �f��㏧M��7E7���]H�Ki���vh	О8�;ˏR��jo{�QC�G{+������G�����J�#߻��S���ۅs��N��'�7���w�ڜ�r�;�`��8 h��<����'��w�kW� I)oed�n��U�!�a�C���|��a�j��!���G[ڄa|�8�<�aڡK��6��x��k�8@�?M.�y����6X��S��xBy�x�8 �EyM_v	 ���4}�%p@~j��4}�%p������e��]vX���e���ge���%�@D:��{��k��Kp��e��t��`ڡK���2�#�`ڡK� {���	������PH^�����W�}%d�w~D][.���)p���U���.���7Y�S_t�-�`�e��󓗾�ӗ]p�A�g4c�K��Yu2�,���O��4���~�.�$����h�e����2�/ѶC��Mw�h��K�@S�����/;�Oh�[ۗ��9a��6ھ�8`6�/��e���ɒ'�$ׇ>���̥n��C��r������'p�c��C���ٴa4^��}��m� �n��zI�����Ӱ�L�C(��2\ b3ӫ��J����K`�M���I#���,p��:�d����R����e$p���%qN��G�*p���x����T��J����Gݪ�}6����x�*p�xrG��5�Q&O�������'p�dAA�v��>��^�n�WC��I�ډ�d���������E@n�����$`����>m���'p�䠃e���'p@Ք#��v�8@�7��m�N�d�+�P�v�X 9]%&U��}D=�T��}�NNvp�S��N�\��qj8��̵p���Oí��&�f3�n;�	�����qjX�l���C��Yc���߹(�^�����8`V�ډ͂�ut��xiևNY��水`~�)�@�<s�1���},p@}����)`�T�o��>t
П*G�ǩI`�\=�`i}�0@ʞ�޾Y:Hf�ǩI`�lfB$���$`�~��k��^����?&��[::r��~����'�`__Y}/���O`��J�V���$  yye��k|=�d!�f�|h,��ܐ}�7�&���t;:
���~��qjl�-I/�u�rf�����@ɘ�ˊE4"�4��\�%���$p@�{�
ǩI�@n�x���ˠ�	0�p��Q���ȝ�5��v�\���;�J�~���7�8��M�/���Z0@��,s�����'� �����dFWߝ
�P�ӷ��rB ���7Y�S�uG{}�w]���@�x6�Z�4j��r�qS�FPe�e��b���ޥ|��)Ȩ��x5�3u�:#���d�UH����oa���[qc�]J5���R8`z�^\���WS�q���-�.4')4��$	,�A�|Y5|���(��j8����m�<��Q���	�Z��%.����_͋�#��n�oS$�}��\/b:�7�
rձL��]*+,��2����G�KA`փ$ �qP��nXဪC���b�$Ũ�C��o�
�+[5k,�
$=!Vcu�S8 �1��ٮ�����]�v��~
�t��{kjt�i+0���P��U�V8@Nn�4xմ6����>�p@ћ4jJ^5m���Х�4�u���@b�2e���(u)�$���ɧ�ߺL_A����r>��8�����r>��r��{ӧ�@�t9UR��6m��/��X�n۴�^�R�[�p@y��9��~
�̽W������{�E<�^�
dKh���M[��d�Ú���i+�~k�Ujt��	�����6�~
����TMAmJ�.r���m�
��|9��鶂NC"�k-nO�h:s�%���S8@n���Sܶi+\Ɉ�Z=�W�
ҫ�ꑿ�U8`�p97T��M[�9�x`כ���ҕ0��f�w����Ye���ɰ�ڼ�{��B�Hk����H�K��O����`�����Q`y�ͳ��l�Y�0��=�,�@İ<�]�����Y����=_��:�7N�2�s�'^T��#���3Q��HaA�ړR�p�`��@i�I�`�����6n�HႁQZ�6��� �}���k�R������ƭ�m��ů�[3R0�2�!�ڸ5#��f.���WK[a��CD��}�OဦW8���O
[��Eaf����
N��A��#���g~~��eF�@Y���އ�X@ �:��(0�)a���    �Y`���`x��,�@A���uۍ�)ؠ���;ɂ:���5_hW����|md_���'��p�xX��9��[�
+��@B"I\�[Gr��D=TGv��$�^�v�7ᘮ��J�E�o_ �>���6��(�mk��0�I��'��������6�矜e����ʂ>�.���m�fIG:�D����ǁXp��v+� K��r���e6O{
���p~�y�]�,�E�0V�y�]����,W��y��8`zt��v��Op���_�m��Ôy
ti��הy
,(�2hm!�e.��S�	���)p@�k�Z�>t
0t�[�G����@�]A��m��vh����C���(��`}�8`N�1}�e9n�>�^9A� ���`ןd�(���D3,p@�{^Z����uv�R�1�O����=��;�;�8�?�I�N�[�@r�?M&�-��0(�����SC[���RIQ�b���p�Fnx��+�X Y�$�آ�C[@ !sRGۗ^��-�@2�H|��vB.s,(�$
�R��\z��D��;����n�ڳ�2?���.�%χ��9P��m��ַ���8`h
Ɩ<�Y?������gG�zr5�����!\�����w�-�, P^\ށ�	��`�I.B�v('��I�/�ލR}��Y�n���/s	��/l�o���X�����[n^����Rakq�-�,p@��F[�Y��b�W�4�B�]�m��������Z�^���Yò��>�	,�+R+���2���r�Z+�}�g$�ъ�C��s�%��V\�ht�$�J7_�)`���/�ќ�2k>R���~��f��_U���v_��M��h��zw�J��N-i�U�矶�r�X�l�j��X �d�n5;�e B�+j�v��Ϲ@_���i��S� �%�x��O�*ј��Rm7x
����H��3;+�-�*�N�V���O[��{?�}��O�,�?r�fէ�@�4�������X�9:���l�z���0�US�)` 7��˭����s���ӫ֌ǟ�ZN�*/ފmMN�	4��,�������Jr �к�>��� `��uè|e�͚��P ����A��Pd�q���h5,�qV��P���X� iqEn�P5��V���f��(QV�[�^���9���T~�K� [���Ji����pX;#@4�W�'� �&\.�l��FW@�H6I�o�Fr�����6<ڂ�dXb��w/���P[����W6�s�V��u���;k7Ll��!�}�ѭ�Y���x���0�a��ۑ�ڔ�	,�i߮�&�".�7V�L����~�r�V��Z��V���t�7s����D��j
�Y��.���Sھ~e��$�`���<�8`-����%�@"����fm�W,Ù��
�5�~���%p��Ť���P�n1Qp��x���=X:�J2���C�,?���T�,�iO���G����t��Ճ��S�@�/$�ٽ2?d����c�p�F������@��_�j+`а	_v��[9�s�2ye~d=V���_�8@�(�w��>��S#~gu<a,�=�rL��旹"fF��|h�(Y>�W��
�48ޯ@�8�?ENn������e�����O�`H���C[`A
z�|O�/;�����m���\�=y>�d�l�2��h�	�p`��}���O���?m-�0 ˶���"\N�3e=���'p@�{{z�Q	P�������$p@�c=�'�mn�q�7��/����O;@VF�̜Ԑ
. 7�a�Z�\��) ���[�z���0�$Z�y�����ku�r	N �v:�����}���^���]�Pr�y�^�_�8 ��B�H�N�p̔L�a���k��U0��'H��;���r9n����\g��B����\?��Җ"�\/���K@@�F4�!�K3e��
@��2��>W��)�ϻ��V`�|2�����Pֲ��A��瑀AG��@�J�	,(��^�W�'`0���O-��' P�-�}^;�mZ�ٍ�M��)s�i$��DN{����`Nx�j��t����`�K��:O)�Q�C����ȹ�ނS�X ��mN��*dK���e��4���"A6K�f|�X�n�����%� �(�[u�v. ���T$���L�����r�_b+p�Xo�Y:dY����ևN��5�ևN��t[�J�^����JĿ�䗹n����+�X0���z�>t
,�r�ִ&����/�����Ӟ���⭘v�X0o@��/s	,�n��A�7�O>�q}��-`��}M����2���D ��H^���&������^����m����O`��B􂺭~�K`���Hmx>��O����m���%/[��%��̡��C���)` �4/�x�W�'`���c�׶C��I�-���&��O`AY~;8�M���=^��4������'`�+�>��C��@�� �uow��tM
1^���rTY��k���A��%��8��m$�A^���Xf��<�!r�u����0h2hA�qe���uE��(�v<t
�eC	u�L���8�)�Jd{��&B�
�P��Ʈ�Ό5���uMA�\7*ϵY+`�q^L�x��Zt�8W>}�?Y�g�ǳI`�\A����C$`pu��R�u#��9�� �����;���Y]z�i�A)�P��2���uǢ\ �s,���D>D�|����L���.�l���	d\�PeC�Hɱ܂d���F��iO�t�����rW���b��P�>t
5n2R��Ol0�6�%]?W�j+`P0�H�H�C$`��E�����ze~���Rf�v��5�PC��!l���9P�����S`�$���rW[����r家t=,5�;�����i�W�'p��<r����I?,Ǐ2U`�lђ�Q^��%�@�@2��x픹�4�Qz�Q��e����T�	��>�	.а�M��N�C��r�n;A�ևN��e�`�C��C��� >ʽ��tc+�<�b}�0@2����)s AkV�C��A�� �\{���@��%�et,��r!.n/��\������j��Q�]�⾚7G�нW�H�*�	0�Kj�H�N��F���[��C,p@Z��:�%����:ڽ���t��RG��2l�a�,�W��|�
�h��_�����\Ȥ��\�%ؠ�,N�EY_�|� 漱x3�o�~YJ�,f���=/c���힗���()�n���s���Z���诱<'��A�)-�b=��% �d�%i��ѱ܂ �8+��]ţ'~���}N��6�����-ф#E����%� �7%WZC�V.���/FR�S矂Ȫ�<L��i|����P;�p,��Iaڥ�ƽG��zC�<�2�2O�H�K6	Ѭq�Uc�	dz%�S,�=��Nk�Hqj\ a�'	�Ĳg��{��|�Ci�{^���[���۳��?#W�wD��
�"Co�c�[���|��l9��k*�T��w�3�k���I�)����U���S��4M淞
�'HDk�ZG:��flt���` ����V0y),@*���!�ǲ�����iJ�)d	��U���
MV	0�������N$U��9��������9�W��	+�Ru{l���i��z)t�3�ᇴ��mt]8;�[� =���i�L?�����s�Ӵr_
$�52M;����,�cr/�t
��gӄ[����^lV0��8��� H�H�&��Z����X���o~5�ڸL#�/?Cݟ"��ǭ�|�9࣋�<�@Z�T�O=�O~.6�8��_Nl��Tl���U��l��k��
H�ӻ�Yq��n6F��^70Z��f睦���䨁f������S� � �D�lVX�ظ>p�K]
��|8�ԥ� c�W    �mǅbӴ^�?+,��=�)5�t)�$sE+A{�Y� �q#�4�駸��/��6��f�<$��^�Yq����C����f��8b��p��@�-��h`(�͊��'���3^N&o"��	�����#w8b&o"D�plm�v��S0�z���M��(nn/S��$9)�.���+7gj�r~XA@�#���n��_�2�7��	V��9�Ox%�� ��)� �B�p@|�*�ܟ) ���k���/��^n4�g���Ft�g���ʽ��
���g�����5��u)���H�~/��b����KႡ㲚��
$��>Mˏߚ���'Ⱥ�`�V����c�)�
H�[������b>oЗ3<�OA a\[u4�^�t+0'X������Ms�L����v&�QP���l6�6�
f��u4زy9��hՆV����R8 ��[�K]
rռ�Ӵ��.��<E���R�b���\�Pܿ�7�� �?�V�����V0��JM�4MipE
kέ���R���г�h)>�
r네o���n�n��w/�o�
�6��^������Z�o��V0�E�C�w��S0Ј��T;CH����7m�$�	�x޴(�kk�z޴8������{�+.��f�YYM�7�
�)�*��RO�<1��AM�7��d|��{`�M��@�)�_ttXo:�&�֗cۦSA`Β�\�.>^�M��v%㦈i<�OA@S�d|���t*��^�Z�m�N��|�o|B�R�q�SaA�zhh�Zo:�d��M��S?t��C�N��z:R\ [R�����M�`��[l��[	R8�鹵½���78�?��{��e4�t* �'�ԭ`��W��?M��[�����ũ�p@�+K�i�Qj>/9A�Ka�i�~�`��z�O=t��?�&�Yߠ5<�R?���	���ٛ�0��=o�
��I�4���7}
�iA��`Pq9�:b��i+,��z���9޴��]�R��[��s�'����M[a��ûVS��R8��F�i:�^
d˲v��sk��ы�5����@j��.c���M[q���"�45�t),��2�m�9) w�j5�ԥ`�hn_���+�S\ Jt�Q��xӥ� ���p�vS�X �,�Np.9��o���V�9dŮ�����&�  �鬇��ipL��Us(L�x8�U\ K�r~V��[�6��4����D�s%Y5�r6�v���"
v`"x�ظU0�A�o!�r���P"Z�l�<��w6h�ʀ9�
�E���HA@7DW�YWfm� ����R����-k��)u+����k��U0�~`�,\ٵ��@A.׊	m(���[aAy�\�4�N�[q���"EӠN�fJ=�z1�4���Sq���ՠ5l��T�`�KT�M���L��e���SaA~5��4��t*$�X�j��T�`m�����j��R\@�8s��k-��TX I׆�o�V�T���7]
�M'�xӥ��N�$�
G�Ø���w%v�rp�f��/V���ly*�o-\����'E��ྲྀhLO�p�۸BK��8�FW��F5�̿�R\ b1���/����d�dK�D����[5��
��鸤5���b��v�H�-u�v{+.PW�c�x��m+6�+�#����:y).���5M�;M�1=���QK%o"l�X���
8>�t�ڳW� ��4~��┺�<��N�½�S�A�.G�����~�M� �����#��~70�p�JU?_�딺�؏)[��%�?��2����\�[$8[�}b[J �T���`�|26Ņ�Iyd�t+6h8�&��i�iJNA
���9��;,V�`��c
jڸ�K�YMU��s���@�)�a�N�[� ��4��}�R��@F*v"��1݊`�8�Y�H���<�p@�́�4�RO��/3��шǗ�R8 �NP���
�u�h��[ӭ8��x�f��`���R|@�3e~�F��
T[����M�r���&V�8�J�c��>�&b8��Y�2TF�C�K]
)�A:�֐ӭ`P�kc�C�L?�ae럦�7W���a�'�1��z���I"�Դ��K�vx�������ɛHA@��/����c�H������KqM�')���3����2�r�o�F�t)�,G�w0�ϋ�&1f��O� J@��L��~
�M�b�{:VX W�$��旺
" /B)1o�p�h�R@��"�U0�m�YM��Kq���1��=M�7�
��Zo:���i�)y�����F�]M�7�
h�C�j��t*.�УH�oJ՘�
k���5Yo:t�Dz�T�M��e�ωڿ&�6]
��-"�9M���S�A];a��ܑլ`Х�p|t�F��S\@���fT[Ĝ�驰`�O�0n���&V0��]���x�~�H�Qd����ʦ���o�5�f17cz*d��LY_NwL��9v��&
i��n&�XE��fM���a�o��c���>�SH�H��n�&�o�.#����b��R0�}�����K� ��vW�f���Ή�zөp@�_���0���J�M��@��l=��n�tk��Q��֛N�
!W��ijڦKA@��*�N}��L�A��
�5\C3F�b�'��Ɉ�is��7]���Z苭䉤� �H �k=Ucz*��ڋ����p@���)�
�yu��TUX a����/u)\�G�b~�Kq��I\�b%8�hLO�	du'�us@l4�'�(��5�p8+�D^Ҧ�o-\M��r$꾽،7]�D�l��(}9���S� /�.��2\��`���^��J��@��p�S�RX0���%�؃_�R\��Oj����Kql�z�N�F
��b�����y����=�L
ԧ�7Q8��rPS�%Ia��3]5��R����p�!���֥�@�,k�և_�R����H�tV�[ѥ�{��6+.0�2�krD�[O���D纒�* ��]Q���V���(~�K� Yu��w�V�~
��y�j��t*\���"��Yံ�:�1�^
ȁr��DqtV�@���ȇ���K��I!|�^�M���C�Juz��p���0��[/��Q��5mӥp�\z�aj��R8@��ͯ� ���V��L�t)��S��:�R���ᚤq)o�Hki=�6]
̹"�)x޴�uW�4��i+0{O,����j���r�z޴r�6����)������WM��9��Դ{�)P���ijڦKa�$EЗ�qtR0X���?����),�~c��qtR8���)~+��Iq���w���7�
�����Ŕz*`���}S�mө`PeW�@O��m�N��na�m�t*����ْ��m�N9,������)u+H�����8:)`�n�����iO��L
���qtR8@6k��$�ӝ
��#s�4�mөp@yJ�R�(�R0��'��8�N
ԧ55�K�9��m:H�	����IဲvG��^
p�j8���)�|W\�<�Oa��Z��_
�l�m0�ڦ� ����{�8:) ���e�ӝ
��� ��40[�@��6s�KA�`=Xw���y�V0�t:�S<o�
��+jj{�S��]`Ƒ���N�%���T<o�
H0U���u).�Ủ��b�M��eFIG'���:���qөp@}bW�淞
٤���8:)�@y<QG'��Љ$ax�Վ�O��'�=4���� ���֩ӕ��*,HaN1�'Ɉ9�b��v�t*ОT�y���c�蚫m�N��*7j���;���Yo:z��4��S� ��~t'��Z�I��p��c���m:�/\�k3�K� ڨ���N��|�͎�O��@��v�t*0V��lOw*,�6�'������8w��m�N��ڥ�z�Qj�]J����T;
?(��I�vNw*P�&�i�M��]��OS�ӝ
��7��X���@���v��mӧ�@69j����/��ʆ��oZ
�' Z	  b�v���Kဴ���Û��y��I�7-���1�?�i)P�$^K��MK��i e��p��t�hc����{��MK��䠿Վ�N�e]����t���Dvb��a��L�tKး���9ݩp����E1��GO��+R�_;
?(k+o~�tK်r�f'~*T�_#;��S��a��)�rR8 <{�?H�ͼ���m{US�m�zC�4uۦOaAx�R�i�M��2��jrۦOး6�f'~*��w���������H�m�>��C����p�D������>��od�=� �jZ��M[a��ij�=o�
���8�b��7��
C�FM��yO9)���ij����@	8.���<oڊ��n���X�ʴ���OA�2S,�(O�&�L{�Yှ���~���|s'�/BU�����A�Zj�J�̪/UK���`o�X8+,����"ȩ��p^H#�Լ�́rD����W�`0�c���:���)0�q�C���ӱ�@��+I�\��8��/zOdl�9r5]
�[�)�2�)g����l��R��
m�d���K���b�^��)u+������L���J\{ʭ���&�|�­�ӹ��9�MV� ��|�)�
ptAM��[?���u@p�)�
H2E��kO�U0�)�-ⵧ�*f?���x�~
���מr�p����{-�7}
��`�מr�p���0��Sn���x��zӧp�x�:bu��SX0G���&Wכ>��d����M��q����7-��J���oZ
��I�����
�T���
ԕ�<_����m�����TU8�ϖ���
�u�1_iR������'���[���^��W��p@|
����[���6��}�V�9w�
w�b�V�9d]/�7-�d7?\���p@_���~x�RX �.��5�޴��p��Û��r\���p��ۅ��oZ
C�1�^�p�p�t���T��S8��5�W,�*0_�6���(U�X���S�a\^;>s��M[� ����z��� ˅�x9����s�����t[ဴ2����t[A@oXX�#;մ���$aM-�zө`P��n�V�6�
��/�zө�@���.�<l�t*P���ij��T0��F+Y^�6�
�$>�4x�~
z�Y��S�h��Sa�ܘ��Uy�7�
�rp��7�
���}��<�V8��>{�Ԏ�N�$�ְ��
db��iy�(�T8 �I|����R8 �LW�Jn�n���m�N���S[�m�N��z3�֐~<�*П�ƴ�ӝ
���M[ေ�%xm�VX K���`�M����$C��V�6�
wt5�;�;"��jV�m�t*N ��qQ�.@�h��R�n�G55�KA@�,��'�_K4mӥ ���r�J4�t)����7]
�T55�t) �x8b4�t) �����Uံ2җhڦK� ;�*�i�dڦKြf�%y޴(��I�m���Φ�y�V8���AJ2�K� 9��>'���R(=؏X��M[q$r�@NT�dz�KA@���M�dڦK�A\�ԣ�����&RX )�����7]� �Μ�t�!(9�SA@��'��A��M��@��c�Xr2��
�%H,9�RO�f����TU�`t-��(U�<���r,���/b�Pr�J���d���[iN��ccE~Jy����[��j�c�p@[�
��I� 9��/�n%H� �լ]�­�d��?��3V5U�ԥ`0�f�X��[?��J|\
�t� ��]����t+6Ȩ�Y[hJ���@�!�xW[�J�&R8`�5�׾p����p~q�^w-����@L���S(ΊH-w���9���`�W�a%���|)H�q
��Ya�,B/�(��I�X8+���U���3���q�``��#��z�~�i�.��7���y���њRD��O�jj}�Tl�HT���ښ�{��
�?'nw�
̉��R����߿���=� ʑOxb�R?�r6�]w���m��f�+)=x����HD�_T1��Yq9�*c����OLF�r^�=I�^��)a��vP��^�6��8`�����3��X Q l�-=�Z>kdܛ�֫�P��RX0[��3�qwZ�p@�� ����HHUG#��.���:�+�S�Ccj��R�b�c$��j�G��;N���i+��p�LĚ[���$���ي��{ �OF��=](��
��?��'R0Xaѭ��7�mB�0�������ȕ���[�n͖�+v������r�3�6һ%��:�_�D�$����x��"�����-�      �   K   x�3�I�I�+QH,*�K-�2�JM.*�,��9Sr3�L8�S�r�9
��@aS΀������r��=... _P�      �   I	  x�e�Kr+7E�U�q �O&f^A��|I��������)�;�U��ԇ��7Ͻ�a��=^���u��~����������6Zi-�1��(5j��/����QSʵE�ź�4���f���\J�U�[^.G��%�=�M�v}\������q��.�U����3W�l#��]	�ͤ5��R��-�^�l]}�:�pZd�nc䞢syٞu��������x^^N�R���/�����RJ�Ks_�����$��Л����FZA��uN͚
+���=�&�������|�i��Xkm���{���&Mg�!�܏"���B�-7ף�$N���Ѝϔ(��Ml����^n�헒�[����X��g���G�����KӫD6_�H0�f������eL�U��т/aW٤��ח�n�R����eMB.~� ���hZ�2���s�=�ڧ����jK�wﳯ=����Ⱥ���]��v{\�����'��r[:��If����]j�S]]c
Y��}T��"��
h{������]�������������v?U�I[j�-tD��3m-�T��������ZrZkeԳ8�$m" �=բO޻�v	������y�~����������횷 ���.������h_=&`ij΋h�l�9�m��Z�#����:�B���o�.��}�]ua;������v����f�3�\��F�bL�J7G%'�#؈#�]n6rR�Z̹�* $_�-�j[�����������SIgʄ���906��e4h+!zUC�kN��K�r���E������K�eײ���.���ߧrk&�!6ꊳ�5$�0)��_V +i�j�X+ŵ��������PW�YZ��i�a��h���41c�Ә'�V�%̔XS���n�z-�U�\�|�c��&�å��4ۊ��L��rz��8U�V�#�TIݛ�,�%?��+Y�Ξ�J��J
�MQh)0�]��;���������=���W����T\�=�1��S�݅2���9&�����"Fj���w�E���\����<k"�F/;�ŭ�f,}�.�L���@�@VK
�&�s�u����]�l;S�u[s�;$]�����- ս�%}��AɰC�Yq%T�S�Ʌ0��/1�����#}*���O��	����g���f�1��B%O����3L�ߚ[|1�O7_����TFט�YO�J%�D�g���iqxq���9G��}G}��#�:B��ag��m��<��'�.3�	�r]�A���cHߥ�;8!�ϥ�p,��I�"��!o�����~*��L�j�i�XZEN�Wf2��k���Ʀi�4m�f�g7S��8f��_��=`�B��B� '�Z�<]A��V��Z��D����b�qs�Eu��V�c��M��K���r���/�/�ú]ک,�M�؁,F4N��0�7B�`%k�
`��j������P��~|��~5q��v�[����	k/��WJ����O���c��
L�M���6V3�B&nDGv�6;�Xt��m�}a�F\d��Űݮ����E�����gr��)�I���v�.x�w(�
c0�І���Kg�A���-	����n�+��xr���ϗ�	�j�d��X�J�Α|��h�!C�f�����ЙG�Y)���b��Խ���z�>9W��y�6���u;�kG]�2�ɍP@tQEI2�EB�P\3�X�o���!~s
 �CM�ȴ����\g�#�Q܁K���ױph��B��H�m*2R�q��氋�#�t.{)[:R��z;r�����B� >��s!��GP�͔����QW�(|VW�d&f�w	0�7!���r�ϯ�qyy���^>�_u�4��@,;(��T��>r\2lQ�+ʇ!�����>���DcBRf����d	�P�6�,���_5K6�l9m��������s}���|�q��� ������r\�������G�{�F�������'��\��Ú���/5��(��z)��F4k��zC�#R"7=t=1L�f�#�W�nZw<�솻E���r���Ǐs\�x)a�q9�2.	v-q�d�HD;̩�>��<��Z��Ց]�.���QF�G5�r����M��������4ԣY�
�]�<>Nu�w �.��հ<g����d'�)�ԕKY�d��ݏJ\O��ΐ�����gD�m~|���FL�����~\�5��i�U��4�y83�����-��u��z���Tđ����`<�<Wd�h6I��,"]��$����p4��F�fĝc� �!��Kմq��\/���>���8ϰ�v��ȳ9�Q���1!Q��#���/�Q=r��!Ɉ��鑳�h�t��}��gC��      �      x��}뒛J��o�S��ӱ{�H���� �� :���] ����y��7�8�0���e��O��}��$%��@~��\k��4/<?���i�I7v��C�ߒ���UPW��˟|��ϐ�3�L�&��H����{&�����]����k���;:����?/��,����	�`d~���Ӧ��/�hގ�����K�@ �.p	�@�C�w�"0�}�A����7}�{�>���'4��)-�� 	y��I���1:��^��PgX��2�YuX "�q˷���5Y��wͿ���<i���W=�v`ߌ�H��!�;_ ������	"����57�O�jl��������,�뤌>)� JDf?|��n�c.K)J�q��V�s�*,q[m��!��j�_�E;�1z�� *b֥�N`J��ѕ
���N�^
��tly��+;:�)S�CVfMlэ�mnۡ��2O�*�nI��c��a���AɸoO`�4��woY�p�me�t�D�w�����O��@�y��OP�s�²]Q���i�I�:qDJ'tJc��������XX�!���.�[�  �.��G ��$�zr�b�t9Oi�є.����5Z5�I�kk�I���L� ]tJ�.
��iL
��ӑYʮ��T�<�m�,���l>mo��W�}�0H����N��6G�	|Z�o_�O���
����������T�������^���k�D�"d�c���C�_"	-�hj�>��b1�/�5	��w� ��ׄ^����@��_߾���Dd	N�|���o�Q�"i���/O�H Ŧgi7�I���$Y4g�M�j�g�7��9�F�o���5^Hޅ�ʂs}��������u�U��E=�bg^9���RnV�am1��ڽ��5sz~�h��@eJ&��f������:��erU��P�ԓl4X�t,27~�Xv ��L	� K-���r�F3�`.'��`.W7o<(g��?&`���-d%��n�zo.:�n�
M} �(etFp4}:�j����jz�4���� 1��w��θ��mJ��������M K���V�[��`F�l�����2\��ԆA���r�2��v��J7�U� qF �8i��dtm+���!�����U����$�d��\�N�dJ��2�"
�^e��^�B���%# d&A��\y2ǖ���}{��ˤ{Em��8={y�����_�s�j��j��ih����Q��-��<[���fMoy�*�ӫ���+���E��Y�e�`
K07rJZR��0Bc��<�fd5�U�uą��	�� s�K�#��D(t`s�n�h� ��ԐȴL$`�R�܋\�Ķ�V����Ʌ���с~�mX����nʗ���C�!� >�A�j��m%�>ti�=��ϩwoB5�/���fS`��n����S����	�A�Xh� �0��?�ҍ�M��Me��|�rl��e�r��m�j���ft�uMXY���m��W�jxܦ}n�����t�r�3��:�F=J�I7jj5��8�tzf��L�ԩ�ש���u��<���ڱ�Īʓs(!� �C��σ�b��<�+ז���Nr��� r�;���m�*�\�[Y|�G�]�p��Iƞ��ֳ���$GS�g����Ƙ��s}!���!�ﵞ����	���}p�R��S�}X�ݣ��յ�+�s ����^�ѵ�4�e؇�bWmn�6��5z��ҩV2���Y�� �1������Xy��«j��,�!�q[5[�e@��ww�����&R���=�/讽)x������¤�Ќc_K���I>;��R���T�_�΂�&��D�6w✩�ۮJ��AU��S��xEM{�L���u��<Kv>Wv�	��A��/|_�t-�^&N+�	�p>~�l�p�Z�o��{�����!��ʛރ��a*{.����u��t9s'Y����2CA�Nm�v���H��&A� }�B�$o!��k���?��]Ə2��rw,�Heǔ-�X���-x3��r�����L.4�j:0��PM�(���&��S���Ae=�����0]���(�2|�����kA�*��m�_���s�S9��x`�p@w���3W��Ͼ�:����v�x$��0[$k#w��I�y?ȝy4㯻���M}�v����+Vl7ss��r9�ㄛ�(:�H�:� 93�p&2�Š�B8]�Lœl�\��5��V[��\Lָܺ�6a��mW^��ܶ�Hͨ�����8�C� ٸ[���ew��3���.ǉ�a+����(�SOmm��8պ)>">���ឤ\4��D����U���&ai-��9�����s�r
����jRGC<M��L���ѮU*CǴa�����qp�f���,m@Q�����Db���'��d�8��	�j58r������ �[~}֗G.�j�n�l�O��v�Mbw9���k���%��0B��U��O�&;=��pR�X��:R
�IpR��.�E:7/���	�G�'�U�eo���4��KƄ�d]H򉳮M[��D���J��B�ϝ92�����ӻ��d�z:Dƭ��.x9�N��)ݥ-�f��(0�+�;{]?eY�Fa����a��@�G$�=+�!�2kn����	������}�k�mʊ"-*hI�ZQ	ESKQm��&�l�Ҽ
ʩx�T����`R��V�æ��'�R���⮒.��Nˡ'h��s��ms��0��]'(jjG��S�����ƂC�"�n�B�>�&~`�������:�$�(i�E� į.��L�Cl��	E�w�>>�iߜ��p���
���`�*��x�D�9*��MCd��@�3�`�!��c~1��t�w0Nbk��iH吺���f�{�,<EC��-��Rp�W��M�z��Q�x������5
���7�(額D'��>���0r�V��t�pk)�8X�]�+?���qS�^��,AN�/�p!M���+V���n�=_���3p)�V�g{d2����
��"D��S	ɐ�~�ĝ��e4 �0��qS�&W���q�n�Q���u�%dR���0�jJ-�2�t*w.�vL�{>u�>ƙuwA#Ζ�: ��:�c��m'uY9�X�FA������팥��Ji����OV��A#�і�p�t=K}jw��eE�|9�ǭ�1�� ��P���l7x��M[F�̮-������0S��M���iK��qsA�]�
��㌁�g��R�uI��r3Xs����X^j�F�����+�����2mгL-���Z�7��XwNO�C�=f�����s^�'!�Q�np�	��`��0������֌����?�Rs��	�%nFk�ӭ�����?�8�m�\�=>&�	��^��ٔ}���XE��WN�흭,èl����=i�":��'1��^�{ɓ�o�"T�����N�z~
�%a�Q0H �]UwA�F�����ppy˘��d�~��Z��%�=�Ah^����?�O�5���`������$]pV��Pt����x|��ȓt��#�IO#lM�<!˩B�aR�g'<��{!ag̓}���\����9b8�+�>��<q�S?�͞�R̕�dm�zs�\�@��zM���%��b�������!۶����5��mNծ0��[?�k���o�$�a0Bo#�DbX�-#`"�<���X�%H �ߡ�
��O]'�:b ���0u?^=e ������=4_=��L'Mh��P��0z�\ŗ ��><!� �$ށ�
����1�h��}~�.�E��ݴ?�i�L�U�I���4������*��?�{D;'"�n";�V�4���]�C�k���O�̕%t�-�/�,h���c�?��FQ�|�w��7����]-�:Z�Gw��?/�6@�����c���\���%�x��"+p��[\�w���]V&Y2����Kq;.�������f ��ȸ��&i�]��U��� y�08|��y�Q/�`�;�{<0��G3"���l�##�_䀆�'$    5<��o��e�i� `�
�Ҡ�Ǽ�Ѐ�EU��_��tQY�?o��"��"/��.��t��i|W0_�b����+9(
��� ֛<��m-��cX��F�&��7F�2��[z�t�ؽ�ec���%�V�ߌ�]�&|��̗$�~�G|��}������"��3_��}�_�O�����E��8!���6=��*�]B���y��t��<G��l�N_�Lo�	�s!l�ݏ�L)L.ɠ�ɀ�2��r���2_3#2g ^�
A�O)s�~@+ %��2�E>u��,��D��x'�t��d�~B����� ��2`Wg=���h�kt����i����f���of�����G��6�K�t�շ"���4���H��0?��>���E:����%��%�?�eQ&�$ne�����稍���o����X�Kq�m�[]{0@D��Y=v�ǣ`�-�X�Ɛ��A�Ż�`̇��'�3�):�'絉�g�7�/a�N��;_��AO�N�"y��sE�OۄԄ��"-������ ���*��1:@A�\�pTV�����B!8��"���d�z�Y�e�:E�����������Lԉ�h	�� ��dk�0r�9cRE�|E��gW|�0t���{'7�s��&�q^�$L�k���DU�Q�CxԂ�djˌ<��D�Y3!�?V~>)�-h��"�x7t_��S�����oo�X���v�0��\�����P�K�ɫ��C�_�dtN��?aʷRe�oG`Pe���[ۥ�\���c�0��f&Px|����*���ڷ+����諉"�L�)aG�C� \���J���`�������)&h&�1� +Y7�U��dR&�[E�O��]�|�P�]�G��W}���RMf�1�2�e��|0��U>�q��*q)����Sf�߄}�g�`�eM�=�V�$>|3R���C���F�Sք��nv�Ч������f|1�~[���C�̑���~�f_�=��MG~;t�E�̬��V[P>Kע���h*�Ho��jv�Ē�s��X��āq�B���B��zE�8��[.��Am��u�'3O�e�m�[��u�{b�����.�z��,?�qe�	�F�u��&\�[C�`���Z�'�p�m��C l0����bmpq,�1�V�s�S�F���DNK�J�r���:�I/�k4�,�5B0�h�l�HZ$l���k��!-�P)�|)tm}�t��RԹ.E�0g��E�Y�d�GMT4�:D�TvsFɋ'�(�*|��<!�{�3�����kB�^��ztj�}�=�����%|�>�R���뫑k9hLL6L��dq�Q�B�u~×�-񚳷q�,��`ߏ���K$�%���Bc!���5��"נ�S�����OD�u�6�/0���z�W.x1{T�夳,ʉ;�r���3�N?���"��@�DA@�`z��RIX�̕4�HY��$&<E4ZZ��
#�l���.���ϴ#_Rv�P��k��{a� �L��v��r�@��+,��}Y΀�@���f�E���﫞�©���_̝c��μ�$Hr#�t��+q�s�� ��Tz|=$�hw�m�O��)^��Z~��bI\��{HU\B�����fО�7���'��L˄>��N� Yd���̂�%��k.XL���>(�{�̪�Up�Z3	���s��8��}�P{��k��u�l�RԻ�;�q�:f�q�KAL�~�����2J�'�n�}4�x�@+ǿ h��S+����?VF�L��"����/�$]L��9���-~+3�8�X�t��?��QT&ã��s7\�5�m�K���e7B��"�u��^!��|�#<�ed�e�����o�z�Ь0b��d��b2��|q������5;��8���p���y�.� B�w�ƃ�0:�0t�k\��sOgz����歊��:.�\�O���_�?�_������n���o6���Y��w ��V��8}����D.�C�EW$� ��M�y�t�>�i�K�7 ק�n�U�w���n}��!:���t��f���P� �3Ʊ��T���3�+���}~�N���M�g�t�A[�p�
~c+ �~�I˸�B�l�њ��Y�(fPҴ���ܨ�IU���y$-	����ڲ��[�+.�#+�A�@n�A���ב��?���2i�>�`d�2]���:��#�LZ�
������;��qO��[+���`��n�3�$fѰ��� W@�qn�>�~�g@%��Lp6�bB�mdX��-��(P>���
���]������Kz�}K=��5/�ZC��F��|��ȳ��q-8p,�]�Ѥ���Y�+�ֻ�����w��f�;�F�E9��j[�aA�E|I�����Ј�5�h�d���!��7͑ �(��3xYE�Ֆ�M�v��<�ۖe����9���,����U\���\^�;�8FCSz�9����;��5�$Q��>�I�a"R�7��X��!����g��MT���U�&R���GfbG���X!䳛�C��A扻����_G_��(�.��Ӎ�$��_�G1��(�6]
���-6���^�ıZ��bUUΆ:������}�ݐ`s�OV:���g��䄄>�xu�w�-��L?����y�`��d�+<I��Zr;�eAٗ��g��bx�!��/H�q�P����������?T?ܧ�B�P|�"��!*Ģ��4KEz,����e�Ք9"�I�.N"쐇�Pu�u����K��Jt�;C�!����-���UN��=�r �)u=g��
}���A~v�w.-�l�[tc���<��6{��'�K�j��PTz�MGÂ��'��$R�V��h��R8���a��SxsC9����ٚ��{i��D@��t�t������>^�6���l�yZwI�OB�H����r⋓��'�=)��H昇y|��o 5TŁ�Z�5X��P�׍�[���V��� o}��e�P$���	0
[V�'��z]D:씠e��u�m��x]�y��V
}���C0��ێ�9`,�h��O��7`��5d�~�m;SGw]�*������ě��Xک،��Ժ#�o#B=�E��������Q!e�`y�A���������������G���H����i��퇃o�0n�WK�1*��-�z8ֹ��N�V�^a9�NQx+ڡ:lu����?b+�V=�"(��M���!7��1��`8����sX��3�sp-�;`����0H/��<N�|�vg�Z���^�'�<�<����]��˾EV�ݝ̍���ضxs�EK�h>����ox��X,}����9�����uBF�����
�k��"W �N�5hqK�h���&�ƻ.�ρ&?Y�k�}�C���k˺.޲nKKo�p���Zu�VIfg�+;�Y��6
t�ֈ��^k5���4�k�"J��(���(@�2��P������?�1KQqIvi0�W}S��[��d��#�]E��g�*�0�@�>[hKG����D*9��aݝZt�'���Ӯր`����i�����t�i_?��"`��8���q�����Hǧ!{��KL���W�m�YM�����#�~�S�16��D��@�F ���/x�4;��,U�Y�S��Pn4{x]@VQ��{��?��|B����h�}dd���~+�Y�_���L��)-�FWW�dI�!�\������ه�#��ڣ������+]�Ib��G}Vu�b鵓z�ܶ�6�n[��~�R��8����)�F�����
8�����G)�1�"��ãY���v���t��F>��'��[#���Cɠ�-;0�� (+�����(��C�eddAq��M�[XU']h���>冹?^X�G����9�Y^��=Z=��FZ1H�����Mox������[&���+@3��4����.�O����0
����5oY��Zk��F<n|jۅUs�D.��d� Mo|����WLQ|����f�]�[J�뾅퓗mƲn��M���Z�9��F��1? b  ���$��XL����%;6lq���l�̾*��A%�ujР�0%���Pu�	p9�/[��D�I����p�������@��p3F��x��^T��	6��C�⁢qT�y Q��|�e����`�g�L�0�Ab)�`g���k�v�ʅ���E�zV��ā�oY2R|
����}�,��pF���xĠB����Q2έ�t�NU׈��<���C���6j�?��U-D���#e1�#h=���ڶ\��w4�IW�}m4C�0t,�U�Y;.3������q�>F]SZ���z�I�z
J!��P'���ܫ���*��J��ׅ�Z��DS�
X��庻�ٹ#�S��Q�I�>XAx�@�����S�����+,�F~�$��Kklj����U�}����o����קjq��V��0Dy��)�d�{A��@D ����f���������T�c;Z:�`�m��=�GC&� ��y
`��B}C�t�z�ޤֹ�T��i���64^(\ݺ��M��:�4Dq^������|4TE+�AKt�p�=���u��
��ڐ��4�A��&~��D��4���a�؞�
�a⤰�KQ��5R��<ֻ;�$RSn"�ɯpu�w�y����E��8��WTWJ|��%S�������d�n�ce��p� Es�(��Y_�Sr
G��],?(���q�c�H`&!�]-�O�����a��U�ݒ��V�ˢ�Ԭz&�n��ۂK��<Ӣ�e�e �uo����؍�S��Ǔ�O��wO	���w$\]�|R��.�v�,���U�$Y��'l\0�9C���9���7����E��R�:���CAPY ��m����Wg<���+���њ�#�Wem�`x�!=���!Kr��φ�ۊ��:�\"ؤayDH,1�&�&��_b� l�h��y�7	A�h�r�݂��h[�_r�>q����8q�y���8�[$~�L�ٍ!�{
 _B�ѻ�ž�K�w��{@8�
���C���ރ|��H�h�Ic����`�$M��N��to�ˑ��z�A�f����7�)���GX��~R����N�q����7&�!gf��#���A��j;�RT�[J�=�v�l��i@C>��O�#�ȧ�÷k�������-C�s�L
���]����R�r�B0K�h�F&D��`�Ԫ�"�ga�m�`M���e��K�r1֖T#'�m���qa�����焠�Ig�^�[����nq�ۈ������Z�³΋^��2����OY��=������8��26��l�"�T�v�ow-�LB�h�6n\tJ�_��������� �>u�W6�*l�pDCqY?})l܎�%9l}<���|�{���=t(,h�rwvYс=Q.ևdL5�$�u7D:z�vr�O	�����5����}�=������_�O�O_�Bk�xBU�)�"Fx~��N�+��e��v���и�wԂ��(�x����D�^�H�/Iߋ� H_���i��iF���������<�����$}��I��W�o�g����B��g��܏-o��׼rLb����$�(ȳn�ƬNe��I�wc�f�k�u�D7L��&��w+�����3[�<w��:J��A�:?��<�'�{Ɖs���p+��	e��}�4k�{i�o��t��}4����t9i೼�tG.����YзQ�U�����E��a��0]�%�7�vh����"Ckd�������=�t܌"=~���9m������O	�u
�M�>�2�,G�*$T��݀��!�@�A���-)kjC���G�����#-���Eu��*���]���f�����n��;�(��[8ED14�<�O����npE2����ٻ�V�'Q�� 
�g��}�~ �Q�G0���	���.R	����E8���D��O@��~o�Swe8�GX�)�OP�o�k�A�/��2�� ��*��� ���˝ᠹ��08L��n�������eVyI�ʛd�V��zw�g`�W�3�.{���|�>�����a�rAA�
_��!�^�Ĉ�g�O�1�C�ִ�a��s�i��קߏ��~.|��������;�Ab8z��8��O�^�Y�t51f�L@^^�c5e</�S��S��#��M�E������P�4i\E�_�/�D��W0�S�Ui&I���o}IY��]����u�+��H"��8Z�>�.����K/�� �b��~�W��dطt D$�yK'�y]'|�E����!D�>��/���02/�����^1ˇŘPl��X�]�j*�k*�fږƈ*�J��VXX�TF��[�3�����P�sUz�
'-X�~�1�:�B�W�ټ�>9u8�������#k�
��׭�C��l��e�+�?��?�мDP�^���Mi�/����]ݍy��c��i� �?��P���B�L:�����;&I-�H�/�@��>����D#@_�~���)�/z�?t�Mu�bc	M��������0/
6d+@~� ���,�y&pQfu�(�YR�im��<����r1�wc���c�Γ�'*x˜��W-�v�6�.M�S&]�z@֒����c
|�
�\I�7�rx�C�?���˟~0j�?&���;�~��e0V8�N�!�y>�$C�b���B��i���l|K<�Fם�Î�§�o\#�m�?�������fCy[@];fFR�o��7��?���?3����˖2-~X&
�0�w��`�g��Sr�d^�g��eoq��X9{F8bV�a۴�dD�{�vB��ձm)��u�|ۤ�1j���R��#�#����d���I���2u� 9uW���������?���}�      �      x������ � �     