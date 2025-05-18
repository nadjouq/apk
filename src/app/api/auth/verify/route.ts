import { NextRequest, NextResponse } from "next/server";
import jwt from "jsonwebtoken";
import { SECRET_KEY } from "../../../prisma";

// Configuration CORS
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export async function OPTIONS() {
  return NextResponse.json({}, { headers: corsHeaders });
}

export async function GET(req: NextRequest) {
  try {
    const authHeader = req.headers.get('Authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json(
        { error: "Token manquant" },
        { status: 401, headers: corsHeaders }
      );
    }

    const token = authHeader.split(' ')[1];

    try {
      const decoded = jwt.verify(token, SECRET_KEY);
      return NextResponse.json(
        { valid: true, user: decoded },
        { headers: corsHeaders }
      );
    } catch (error) {
      return NextResponse.json(
        { error: "Token invalide" },
        { status: 401, headers: corsHeaders }
      );
    }
  } catch (error) {
    console.error("Erreur de vérification du token:", error);
    return NextResponse.json(
      { error: "Erreur serveur" },
      { status: 500, headers: corsHeaders }
    );
  }
} 