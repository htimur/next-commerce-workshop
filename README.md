> This project was made to show a full ecommerce plataform made with Next.js and Nextjs Serverless functions to build the backend, using Apollo Server and Apollo Client to GraphQL.

  
# :construction_worker: How to run
**You need to install [Node.js](https://nodejs.org/en/download/) and [Yarn](https://yarnpkg.com/) first, then:**

### Rename env file
Rename `.env.local-exemple` to `.env.local`
### Install Dependencies
```bash
yarn install
```
### Set up database
```bash
# Create DB using migrations
yarn knex:migrate

# Run seeds to populate database
yarn knex:seed 
```
### Run Aplication
```bash 
yarn dev 
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.
<br>
<br>
Open [http://localhost:3000/api/graphql](http://localhost:3000/api/graphql) with your browser to run queries or to see docs of API.

### How to docker

To build and push the image:
```bash
APP_VERSION={app version tag} docker-compose build
APP_VERSION={app version tag} docker-compose push
```

To run the image locally
```bash
APP_VERSION={app version tag} docker-compose up
```
