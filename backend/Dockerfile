FROM node:18-alpine

# Instalar OpenSSL
RUN apk update && apk upgrade
RUN apk add --no-cache openssl

WORKDIR /app

# Copiar package files
COPY package*.json ./

# Instalar dependências
RUN npm install

# Copiar código fonte
COPY . .

# Gerar cliente Prisma
RUN npx prisma generate

EXPOSE 3001

# Comando de início
CMD ["npm", "run", "dev"]
