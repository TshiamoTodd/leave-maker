# Leave Managment System (Leave-Maker)

# Overview
[Leave-Maker](https://leave-maker.vercel.app)  is a web application designed to manage employee leave requests and approvals. It uses Next.js for the frontend, NextAuth.js for authentication, and Prisma as the ORM for database interactions. The application also utilises Next.js API router to send API calls to a prisma client for creating entries to the database as well as server actions to interact with the database. 

# Table of Contents
1. Getting Started
2. Installation
3. Configuaration
4. Database Schema
5. API Endpoint
6. Frontend Components
7. User Roles and Permissions
8. Deployment
9. Troubleshooting

# Getting Started

## Prerequisities
Before you clone and run the application, ensure that you have met the following requirements:

- Node.js (v14 or higher)
- npm or yarn
- Git
- A PostgreSQL database (or another database supported by Prisma)

# Project Structure
The project is divided into the following main directories:
- **`pages`** Contains the Next.js pages for rendering UI.
- **`components`** Contains reusable React components.
- **'lib'** Contains utility functions and configuration file.
- **'prisma'** Contains Prisma schema and migration files.
- **'api'** Contains API calls to various external services

# Intallation 
## Cloning the repository

```
git clone https://github.com/TshiamoTodd/leave-maker.git
cd leave-maker
```

## Installing Dependencies
1. Install project dependancies:
`npm install`

2. Install Prisma CLI globally:
`npm install -g prisma`

## Setting up the Environment
1. Create a **`.env`** file in the root directory with the following content:
```
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-nextauth-secret
DATABASE_URL=postgresql://your-database-username:your-database-password@localhost:5432/your-database-name
NEXTAUTH_JWT_SECRET=your-nextauth-jwt-secret
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
ALLOWED_DOMAIN=your-dns-domain
```

#### NB: This application uses Google oAuth2 API to login users
If you want to implement it for yourself I suggest you setup your own Google oAuth API from your own Google developer console.

2. Initialize the Prisma schema:
`npx prisma migrate dev --name init`

## Running the Application
1. Start the Next.js developer server:
`npm run dev`

# Configuration
## Prisma Schema
Define your Prisma schema in `prisma/schema.prisma`:

```
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "cockroachdb"
  url      = env("DATABASE_URL")
}

model Account {
  id                String  @id @default(cuid())
  userId            String
  type              String
  provider          String
  providerAccountId String
  refresh_token     String?
  access_token      String? 
  expires_at        Int?
  token_type        String?
  scope             String?
  id_token          String? 
  session_state     String?

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([provider, providerAccountId])
}

model Session {
  id           String   @id @default(cuid())
  sessionToken String   @unique
  userId       String
  expires      DateTime
  user         User     @relation(fields: [userId], references: [id], onDelete: Cascade)
}

model VerificationToken {
  identifier String
  token      String   @unique
  expires    DateTime

  @@unique([identifier, token])
}

enum Role {
  USER
  ADMIN
  MODERATOR
}

model User {
  id            String     @id @default(cuid())
  name          String?
  email         String?    @unique
  emailVerified DateTime?
  image         String?
  role          Role       @default(USER)
  phone         String?
  title         String?
  manager       String?
  department    String?
  accounts      Account[] 
  sessions      Session[]
  balances      Balances[]
}

model LeaveType {
  id          String   @id @default(cuid())
  title       String
  values      String[] @default(["Credit", "Used", "Available"])
  category    String // Should be a lower case of the title 
  description String?
}

enum LeaveStatus {
  PENDING
  APPROVED
  INMODERATION
  REJECTED
}

model Leave {
  id            String      @id @default(cuid())
  type          String
  year String @default("")
  startDate     DateTime
  endDate       DateTime
  days          Int
  userName      String
  userNote      String?
  tasksLink     String?
  userEmail     String
  status        LeaveStatus @default(PENDING)
  moderator     String?      
  moderatorNote String?     
  createdAt     DateTime    @default(now())
  updatedAt     DateTime    @default(now())
}

model Balances {
  id                 String @id @default(cuid())
  year               String
  annualCredit       Int?   @default(0)
  annualUsed         Int?   @default(0)
  annualAvailable    Int?   @default(0)
  healthCredit       Int?   @default(0)
  healthUsed         Int?   @default(0)
  healthAvailable    Int?   @default(0)
  studyCredit        Int?   @default(0)
  studyUsed          Int?   @default(0)
  studyAvailable     Int?   @default(0)
  maternityCredit    Int?   @default(0)
  maternityUsed      Int?   @default(0)
  maternityAvailable Int?   @default(0)
  familyCredit       Int?   @default(0)
  familyUsed         Int?   @default(0)
  familyAvailable    Int?   @default(0)
  paternityCredit    Int?   @default(0)
  paternityUsed      Int?   @default(0)
  paternityAvailable Int?   @default(0)
  unpaidUsed         Int?   @default(0)
  name               String
  email              String
  user               User   @relation(fields: [email], references: [email], onDelete: Cascade)
}

model Events {
  id          String   @id @default(cuid())
  title       String
  description String?
  startDate   DateTime
  endDate     DateTime?
}
```

## NextAuth Configuration
Configure `route.ts` in `app/api/auth/[...nextauth].ts`:

```
import { authOptions } from "@/lib/auth";
import NextAuth from "next-auth";

const handler = NextAuth(authOptions);
export { handler as GET, handler as POST };
```

Configure `auth.ts` `in lib/auth.ts`:

```
import { NextAuthOptions } from "next-auth";
import GoogleProvider from "next-auth/providers/google";
import { PrismaAdapter } from "@auth/prisma-adapter";
import { Adapter } from "next-auth/adapters";
import prisma from "@/lib/prisma";

export const authOptions: NextAuthOptions = {
 
  adapter: PrismaAdapter(prisma) as Adapter,
  providers: [
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID as string,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET as string,
    }),
  ],
  secret: process.env.NEXTAUTH_SECRET as string,
  pages: {
    signIn: "/login",
  },
  session: {
    strategy: "jwt",
  },
  jwt: {
    secret: process.env.NEXTAUTH_JWT_SECRET as string,
  },
  callbacks: {
    async signIn({ user }) {
      if (!user.email?.endsWith(process.env.ALLOWED_DOMAIN as string)) {
        throw new Error("You are not allowed to access this platform");
      }
      return true;
    },

    jwt: async ({ token, user }) => {
      if (user) {
        token.role = user.role;
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.role = token.role;
      }
      return session;
    },
    
  },
  
};
```

This code is configuring NextAuth.js for authentication in a Next.js application. It sets up Google as an authentication provider and uses Prisma as the database adapter. It also includes custom sign-in behavior, JWT handling, and session management.
For full break-down of what this code does check out my Blog on [Confluence](https://loxtiondigital.atlassian.net/l/cp/Bjdc5Pw0) 

# Databse Schema
The database schema is defined in the Prisma schema file (`prisma/schema.prisma`). The main models are:
- `User`: Represents an employee or admin.
- `Role`: Enum for user roles (`USER`, `MODERATOR`, `ADMIN`).
- `Events`: Represents the events that eployees create
- `Account`: Represents the Account information and type for a user
- `Session`: Represents a single user session
- `LeaveType`: Represents the type of Leave request
- `LeaveStatus`: Enum for leave status (`PENDING`, `APPROVED`, `INMODERATION`, `REJECTED`)
- `Leave`: Represents a leave object
- `Balances`: Represents the credits allocated for users

# API Endpoints
## Authentication
- **Login**: Handled by NextAuth.js
- **Register** Implement a custom registration endpoint in `app/api/user.[userId]/route.ts`

## Leave Requests
- Create Leave Request: `POST /api/leave/route.ts`
- Update Leave Request: `PATCH /api/leave/[leaveId]/route.ts`

 ## Event Requests
 - Create Event Request: `POST /api/event/route.ts`

## Balance Request
- Create Balance Request `POST /api/balance/route.ts`
- Update Balance Request `POST /api/balance/[balanceId]/route.ts`

 ## Example API Route
 Example implementation for creating a leave request in `app/api/leave/route.ts`

 ```
import { getCurrentUser } from "@/lib/session";
import { NextRequest, NextResponse } from "next/server";
import { differenceInDays, parseISO } from "date-fns";

type SubmittedLeave = {
  notes: string;
  leave: string;
  startDate: string;
  endDate: string;
  user: {
    email: string;
    image: string;
    name: string;
    role: string;
  };
};

export async function POST(req: NextRequest) {
  const loggedInUser = await getCurrentUser();
  if (!loggedInUser) {
    return NextResponse.error();
  }

  try {
    const body: SubmittedLeave = await req.json();

    const { startDate, endDate, leave, notes, user } = body;

    const startDateObj = parseISO(startDate);
    const endDateObj = parseISO(endDate)
    const calcDays = differenceInDays(endDateObj, startDateObj) + 1;

    const existingLeave = await prisma.leave.findFirst({
      where: {
        startDate,
        endDate,
        userEmail: user.email,
      },
    });

    if (existingLeave) {
      return NextResponse.json(
        { error: "Leave entry already exists" },
        { status: 400 }
      );
    }
    const year = new Date().getFullYear().toString();
    await prisma.leave.create({
      data: {
        startDate,
        endDate,
        userEmail: user.email,
        type: leave,
        userNote: notes,
        userName: user.name,
        days: calcDays,
        year,
      },
    });

    return NextResponse.json({ message: "Success" }, { status: 200 });
  } catch (error) {
    console.error(error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
```

# Frontend Components
## Pages

`app/(dashboard)/dashboard/page.tsx`
- **Dashboard**: Displays an overview of the system
`app/(portal)/portal/page.tsx`
- **Portal**: Displays a calendar with all approved leave requests
  - Displays a **Apply for leave** button that loads a modal with a leave application form
  - Displays current year leave balances and credits
`app/(dashboard)/dashboard/balances/page.tsx`
- **Balances**: Displays a user table with their leave balances and an option to edit those balances
`app/(dashboard)/dashboard/leaves/page.tsx`
- **Leaves**: Displays a leaves table with user leave information for a particular user and an option to edit those leaves
`app/(dashboard)/dashboard/users.page.tsx`
- **Users**: Displays a user table with a list of all users (only visible to **ADMIN** users) and an option to edit or remove users
`app/(dashboard)/dashboard/settings/page.tsx`
- **Events**: Displays a form for creating events and a table with a list of prior events

 ## Components
 [Leave-Maker](https://leave-maker.vercel.app) uses shadcn-ui for styling elements.

# User Roles and Permissions
## Roles

- **Admin**: Full access to all features.
- **Moderator**: Can approve or reject leave requests.
- **User**: Can create and view own leave requests.

## Permissions
Permissions are managed through roles defined in the User model in the Prisma schema.

# Deployment
## Backend and Frontend
Deploy the application to a hosting provider that supports Node.js applications (e.g., Vercel, Netlify). Ensure environment variables are set correctly in the hosting provider's settings.

# Troubleshooting
## Common Issues

- **Database Connection**: Ensure the database URL in the `.env` file is correct.
- **CORS Issues**: Configure CORS settings in Next.js API routes if accessing from different domains.
- **JWT Secret**: Ensure the JWT secret is set correctly in the `.env` file.
- **Prisma generate Issues**: Ensure to enclude the `prisma generate` statement in the build section of your package.json when deploying the application in a production environment. 


This documentation provides a basic overview of the application, an in-depth documentation can be found on my Blog on [Confluence](https://loxtiondigital.atlassian.net/l/cp/Bjdc5Pw0).
