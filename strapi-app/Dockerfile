FROM node:22-bullseye-slim

WORKDIR /app

COPY . .

RUN npm install   

RUN npm run build  

EXPOSE 1337 

CMD ["npm", "run", "start"]
