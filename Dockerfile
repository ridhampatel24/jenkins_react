FROM node:14.16.0-alpine3.13 as build
WORKDIR /app
COPY package*.json .
RUN npm install
COPY . .
RUN npm run build
COPY nginx.conf build/

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf
RUN mv /usr/share/nginx/html/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
