# 🌐 Deployment Health Endpoints

| Type               | Path                                      | Method | Description                              |
|--------------------|-------------------------------------------|--------|------------------------------------------|
| **Readiness**      | `<https://{service-name}.easycontact.ai/health/readyz>` | `GET`  | Basic readiness probe for deployment.    |
| **Detailed Health**| `<https://{service-name}.easycontact.ai/detail/readyz>` | `GET`  | Extended health check including dependencies. |

> 🧩 **Note:** Replace `{service-name}` with your actual service name (e.g. `api`, `webhook`,)

---

# 🌍 Environments

| Environment | Base URL Example                               | Notes                                  |
|--------------|------------------------------------------------|----------------------------------------|
| **Dev**      | `https://dev-{service-name}.easycontact.ai`    | Internal testing and integration.      |
| **Prod**     | `https://{service-name}.easycontact.ai`        | Customer-facing production environment. |

---

# 🔐 Environment Variables

> ⚠️ **All secret values must be stored in Vault.**  
> Never commit real credentials or tokens to the repository.  
> For local development, use a `.env.local` file (git-ignored) or your team’s secret injection tool.

| Variable Name          | Required | Example / Format               | Description |
|-------------------------|:--------:|--------------------------------|-------------|
| `SERVICE_PORT`          | ✅       | `8080`                         | Port where the service runs. |
| `DATABASE_URL`          | ✅       | `postgresquser:pass@host:5432` | PostgreSQL or other database connection string. |
| `REDIS_URL`             | ✅       | `redis://redis:6379`           | Redis connection string. |
| `KAFKA_SERVER`          | ✅       | `kafka:9092`                   | Kafka bootstrap server address. |
| `KAFKA_TOPIC`           | ✅       | `easycontact.events`           | Kafka topic used by this service. |
| `KAFKA_USERNAME`        | ✅       | `user123`                      | Kafka authentication username. |
| `KAFKA_PASSWORD`        | ✅       | `secret`                       | Kafka authentication password. |
| `API_KEY`               | ✅       | `xxxxxxxxxxxxxxxxxx`           | Example third-party API key. |
| `API_SECRET`            | ✅       | `xxxxxxxxxxxxxxxxxx`           | Example third-party API secret. |


---

# 🔗 Dependencies

> List here all external systems and services your project relies on.  
> Remove or add rows depending on your service needs.

| Service / Component | Purpose |
|----------------------|----------|
| **PostgreSQL**       | Main application database. |
| **Redis**            | Caching and queue management. |
| **Kafka**            | Message streaming and event publishing. |
| **Vault**            | Secret management and credential injection. |
| **External APIs**    | Any 3rd-party APIs or integrations (e.g. OpenAI, Deepgram, ElevenLabs). |