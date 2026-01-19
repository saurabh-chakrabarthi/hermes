FROM node:18-alpine

WORKDIR /app

COPY payment-portal/package*.json ./
RUN npm install --omit=dev

COPY payment-portal .

EXPOSE 9292

CMD ["node", "server.js"]
