# Guidelines for AI Assistants

When suggesting or creating code in this project, please adhere to the following rules:

1. **Alphabetical Order**: Always maintain alphabetical order when updating lists of services or configurations. This applies to:
   - `docker-compose.yml` (e.g., in the `include` array).
   - `Makefile` (both the help target list and the targets definitions if applicable).
   - `README.md` (the "Services" list).
   - `homepage/config/services.yaml` (items within each category must remain sorted A-Z).

2. **Commit Checks and `.gitignore`**: 
   - Whenever you add a new service or new types of files (such as databases like `.db`, data directories, or logs), examine what will be committed automatically.
   - Proactively update the `.gitignore` file to ensure sensitive data (e.g., `*.db` files, volumes, `logs/`, environment files based on `.env`) are excluded from Git.

3. **Project Files Sync**:
   - Every time a new service is added, you MUST ensure that all of the following are updated simultaneously to reflect the inclusion of the new service:
     - `docker-compose.yml` (Main include)
     - `Makefile` (Targets and help list)
     - `README.md` (Services list)
     - `homepage/config/services.yaml` (Add to the appropriate category, respecting A-Z sorting).

4. **Formatting**:
   - Maintain the standard repository format: Use Markdown tables where appropriate.
   - For `Makefile`, ensure targets are named `<service_name>-up`, `<service_name>-down`, `<service_name>-restart`, `<service_name>-logs`. Match existing syntax (use tabs for Make targets).

5. **Docker Networking (`caddy_net`)**:
   - Every new `docker-compose.yml` file for a service MUST connect to the external `caddy_net` network natively.
   - Append the network config at the end of every new service's compose file:
     ```yaml
     networks:
       default:
         name: caddy_net
         external: true
     ```
   - This ensures internal DNS resolution (e.g., Nginx Proxy Manager routing traffic via `http://container_name:port`) and avoids exposing unnecessary ports unless strictly required.
