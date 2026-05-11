# Test YAML for {{PREFIX}} {{INDEX}}
version: "1.0"
services:
  app:
    image: node:14
    environment:
      - NODE_ENV=test
      - PREFIX={{PREFIX}}
      - INDEX={{INDEX}}
    ports:
      - "8080:8080"
    volumes:
      - .:/app
    command: npm start
    restart: always
  db:
    image: postgres:13
    environment:
      - POSTGRES_USER=test
      - POSTGRES_PASSWORD=test
    ports:
      - "5432:5432"
    volumes:
      - db-data:/var/lib/postgresql/data
volumes:
  db-data:
