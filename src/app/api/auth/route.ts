import { PrismaClient } from "@prisma/client";
import CryptoJS from "crypto-js";
import jwt from "jsonwebtoken";
import { cookies } from "next/headers";
import { SECRET_KEY } from "../../prisma"; 
import { NextRequest, NextResponse } from "next/server";
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

// Configuration CORS
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export async function OPTIONS() {
  return NextResponse.json({}, { headers: corsHeaders });
}

export async function POST(req: NextRequest) {
  try {
    const { username, password } = await req.json();

    if (!username || !password) {
      return NextResponse.json(
        { error: "Nom d'utilisateur et mot de passe requis" },
        { status: 400, headers: corsHeaders }
      );
    }

    const user = await prisma.utilisateur.findUnique({
      where: { username },
      select: {
        mot_de_passe: true,
        methode_authent: true,
        id_utilisateur: true,
        role: true,
        droit_utilisateur: true,
      },
    });

    if (!user) {
      return NextResponse.json(
        { error: "Utilisateur non trouvé." }, 
        { status: 404, headers: corsHeaders }
      );
    }

    if (user.methode_authent === "BDD") {
      const isPasswordValid = await bcrypt.compare(password, user.mot_de_passe);
    
      if (!isPasswordValid) {
        return NextResponse.json(
          { error: "Mot de passe incorrect." }, 
          { status: 401, headers: corsHeaders }
        );
      }

      const token = jwt.sign(
        {
          id_utilisateur: user.id_utilisateur,
          role: user.role,
          droit_utilisateur: user.droit_utilisateur,
        },
        SECRET_KEY,
        { expiresIn: "12h" }
      );

      const cookieStore = cookies();
      await cookieStore.set("token", token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        path: "/",
        maxAge: 43200,
        expires: new Date(Date.now() + 12 * 60 * 60 * 1000),
      });

      return NextResponse.json(
        { 
          success: true,
          token: token,
          user: {
            id_utilisateur: user.id_utilisateur,
            role: user.role,
            droit_utilisateur: user.droit_utilisateur,
          }
        }, 
        { headers: corsHeaders }
      );
    }

    return NextResponse.json(
      { error: "Méthode non supportée" }, 
      { status: 400, headers: corsHeaders }
    );
  } catch (error) {
    console.error("Erreur d'authentification:", error);
    return NextResponse.json(
      { error: "Erreur serveur" }, 
      { status: 500, headers: corsHeaders }
    );
  }
}