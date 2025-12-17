### 1. Entities and Attributes

These are the main objects in your schema, represented by rectangles in the ER diagram.

*   **`clients`**: (Primary Key: `client_id`) - Represents a client.
*   **`interventions`**: (Primary Key: `intervention_id`) - Represents a supplement, therapy, etc.
*   **`intervention_categories`**: (Primary Key: `category_id`) - Represents categories for interventions.
*   **`biomarker_types`**: (Primary Key: `biomarker_id`) - Represents types of biomarkers that can be measured.
*   **`providers`**: (Primary Key: `provider_id`) - Represents a health or performance provider. As discussed, this is a standalone entity.
*   **`genetic_profiles`**: (Primary Key: `profile_id`) - Contains genetic test results for a client.

### 2. Weak Entities

These entities cannot be uniquely identified without their owner entity. They are represented by a double-lined rectangle, connected to their owner by a double-lined diamond (identifying relationship).

*   **`performance_metrics`**: Weak entity owned by **`clients`**. A performance metric log cannot exist without a client.
*   **`wearable_data`**: Weak entity owned by **`clients`**. A wearable data log cannot exist without a client.
*   **`adverse_events`**: Weak entity owned by **`clients`**. An adverse event must be reported by a client.
*   **`protocol_logs`**: Weak entity owned by **`client_protocols`**. A log entry is meaningless without the protocol it's logging.

### 3. Relationships and Cardinalities

These are the connections between entities, represented by diamonds.

#### **One-to-One (1:1)**

*   **`has_profile`**: Between `clients` and `genetic_profiles`.
    *   A `client` can have **one** `genetic_profile`.
    *   A `genetic_profile` belongs to **one** `client`.
    *   **Participation**:
        *   `genetic_profiles`: **Total Participation**. Every genetic profile *must* be linked to a client (`client_id` is `NOT NULL`).
        *   `clients`: **Partial Participation**. A client does not necessarily have a genetic profile.

#### **One-to-Many (1:N)**

*   **`records_metric`** (Identifying): Between `clients` and `performance_metrics`.
    *   A `client` can have **many** `performance_metrics`.
    *   **Participation**: `performance_metrics` has **Total Participation** (as it's a weak entity).

*   **`generates_data`** (Identifying): Between `clients` and `wearable_data`.
    *   A `client` can have **many** entries of `wearable_data`.
    *   **Participation**: `wearable_data` has **Total Participation**.

*   **`reports_event`** (Identifying): Between `clients` and `adverse_events`.
    *   A `client` can report **many** `adverse_events`.
    *   **Participation**: `adverse_events` has **Total Participation**.

*   **`logs_for`** (Identifying): Between `client_protocols` and `protocol_logs`.
    *   A `client_protocol` can have **many** `protocol_logs`.
    *   **Participation**: `protocol_logs` has **Total Participation**.

*   **`categorized_as`**: Between `intervention_categories` and `interventions`.
    *   A `category` can include **many** `interventions`.
    *   **Participation**: `interventions` has **Total Participation** (an intervention must have a category), but `intervention_categories` has **Partial Participation** (a category might be empty).

#### **Many-to-Many (M:N)**

These relationships are modeled using associative entities (also called relationship entities).

*   **Relationship**: **`follows_protocol`** (or `prescribes`) between `clients` and `interventions`.
    *   **Associative Entity**: `client_protocols`.
    *   A `client` can follow **many** `interventions`, and an `intervention` can be prescribed to **many** `clients`.
    *   **Attributes on Relationship**: `start_date`, `end_date`, `status`, `prescribed_dosage`, `frequency`.
    *   **Participation**: This is **Partial** for both `clients` and `interventions` (a client may not have a protocol, and an intervention may not be in any protocol).

*   **Relationship**: **`has_reading`** between `clients` and `biomarker_types`.
    *   **Associative Entity**: `biomarker_readings`.
    *   A `client` can have **many** `biomarker_readings`, and a `biomarker_type` can be read for **many** `clients`.
    *   **Attributes on Relationship**: `reading_date`, `value`, `testing_facility`, `flag`.
    *   **Participation**: **Partial** for both `clients` and `biomarker_types`.

### 4. Unary (Recursive) Relationships

These are relationships an entity has with itself.

*   **Relationship**: **`has_subcategory`** on `intervention_categories`.
    *   **Cardinality**: **1:N**. A category can be a parent to **many** other categories, but a subcategory has only **one** parent.
    *   **Participation**: **Partial**, as not every category is a subcategory (the `parent_category_id` can be `NULL`).

*   **Relationship**: **`is_contraindicated`** on `interventions`.
    *   **Cardinality**: **M:N**. An intervention can have contraindications with **many** other interventions.
    *   **Associative Entity**: `contraindications`.
    *   **Participation**: **Partial**, as an intervention may have no contraindications.