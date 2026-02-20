FROM nginx:alpine
COPY dist /usr/share/nginx/html
RUN sed -i 's@NODE_ENV:"production",BASE_URL:"/"@NODE_URL:"http://localhost:30545",CONNECTION_TYPE:"json_rpc"@g' /usr/share/nginx/html/js/*.js
COPY default.nginx /etc/nginx/conf.d/default.conf
