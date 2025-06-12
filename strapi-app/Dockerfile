FROM node:20


WORKDIR /app


COPY package*.json ./


RUN npm install && npm install pg --save

COPY . .

EXPOSE 1337

CMD ["npm", "run", "develop"]
