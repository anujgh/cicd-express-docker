FROM node:20.12.2
WORKDIR /app
COPY ./package.json ./
COPY ./package-lock.json ./
RUN  npm install

COPY ./src ./src
EXPOSE 3000
CMD [ "npm", "start" ]
