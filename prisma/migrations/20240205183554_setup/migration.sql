-- CreateEnum
CREATE TYPE "Role" AS ENUM ('USER', 'ADMIN', 'MODERATOR');

-- CreateEnum
CREATE TYPE "LeaveStatus" AS ENUM ('PENDING', 'APPROVED', 'INMODERATION', 'REJECTED');

-- CreateTable
CREATE TABLE "Account" (
    "id" STRING NOT NULL,
    "userId" STRING NOT NULL,
    "type" STRING NOT NULL,
    "provider" STRING NOT NULL,
    "providerAccountId" STRING NOT NULL,
    "refresh_token" STRING,
    "access_token" STRING,
    "expires_at" INT4,
    "token_type" STRING,
    "scope" STRING,
    "id_token" STRING,
    "session_state" STRING,

    CONSTRAINT "Account_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Session" (
    "id" STRING NOT NULL,
    "sessionToken" STRING NOT NULL,
    "userId" STRING NOT NULL,
    "expires" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "VerificationToken" (
    "identifier" STRING NOT NULL,
    "token" STRING NOT NULL,
    "expires" TIMESTAMP(3) NOT NULL
);

-- CreateTable
CREATE TABLE "User" (
    "id" STRING NOT NULL,
    "name" STRING,
    "email" STRING,
    "emailVerified" TIMESTAMP(3),
    "image" STRING,
    "role" "Role" NOT NULL DEFAULT 'USER',
    "phone" STRING,
    "title" STRING,
    "manager" STRING,
    "department" STRING,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LeaveType" (
    "id" STRING NOT NULL,
    "title" STRING NOT NULL,
    "values" STRING[] DEFAULT ARRAY['Credit', 'Used', 'Available']::STRING[],
    "category" STRING NOT NULL,
    "description" STRING,

    CONSTRAINT "LeaveType_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Leave" (
    "id" STRING NOT NULL,
    "type" STRING NOT NULL,
    "year" STRING NOT NULL DEFAULT '',
    "startDate" TIMESTAMP(3) NOT NULL,
    "endDate" TIMESTAMP(3) NOT NULL,
    "days" INT4 NOT NULL,
    "userName" STRING NOT NULL,
    "userNote" STRING,
    "tasksLink" STRING,
    "userEmail" STRING NOT NULL,
    "status" "LeaveStatus" NOT NULL DEFAULT 'PENDING',
    "moderator" STRING,
    "moderatorNote" STRING,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Leave_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Balances" (
    "id" STRING NOT NULL,
    "year" STRING NOT NULL,
    "annualCredit" INT4 DEFAULT 0,
    "annualUsed" INT4 DEFAULT 0,
    "annualAvailable" INT4 DEFAULT 0,
    "healthCredit" INT4 DEFAULT 0,
    "healthUsed" INT4 DEFAULT 0,
    "healthAvailable" INT4 DEFAULT 0,
    "studyCredit" INT4 DEFAULT 0,
    "studyUsed" INT4 DEFAULT 0,
    "studyAvailable" INT4 DEFAULT 0,
    "maternityCredit" INT4 DEFAULT 0,
    "maternityUsed" INT4 DEFAULT 0,
    "maternityAvailable" INT4 DEFAULT 0,
    "familyCredit" INT4 DEFAULT 0,
    "familyUsed" INT4 DEFAULT 0,
    "familyAvailable" INT4 DEFAULT 0,
    "paternityCredit" INT4 DEFAULT 0,
    "paternityUsed" INT4 DEFAULT 0,
    "paternityAvailable" INT4 DEFAULT 0,
    "unpaidUsed" INT4 DEFAULT 0,
    "name" STRING NOT NULL,
    "email" STRING NOT NULL,

    CONSTRAINT "Balances_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Events" (
    "id" STRING NOT NULL,
    "title" STRING NOT NULL,
    "description" STRING,
    "startDate" TIMESTAMP(3) NOT NULL,
    "endDate" TIMESTAMP(3),

    CONSTRAINT "Events_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Account_provider_providerAccountId_key" ON "Account"("provider", "providerAccountId");

-- CreateIndex
CREATE UNIQUE INDEX "Session_sessionToken_key" ON "Session"("sessionToken");

-- CreateIndex
CREATE UNIQUE INDEX "VerificationToken_token_key" ON "VerificationToken"("token");

-- CreateIndex
CREATE UNIQUE INDEX "VerificationToken_identifier_token_key" ON "VerificationToken"("identifier", "token");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- AddForeignKey
ALTER TABLE "Account" ADD CONSTRAINT "Account_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Balances" ADD CONSTRAINT "Balances_email_fkey" FOREIGN KEY ("email") REFERENCES "User"("email") ON DELETE CASCADE ON UPDATE CASCADE;
