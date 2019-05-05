FROM node:alpine


WORKDIR '/app'


COPY ./package.json ./

#run package installations
RUN npm install

# RUN npm audit fix

COPY . .

CMD ["npm","run","dev"]