From node:20.12.2
WORKDIR /app

COPY . .
RUN npm install

CMD ["npm", "start"]