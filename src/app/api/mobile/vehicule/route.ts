import { NextRequest, NextResponse } from "next/server";
import { PrismaClient } from "@prisma/client";

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

export async function GET() {
  try {
    console.log('Début de la récupération des véhicules...');
    
    const vehicles = await prisma.vehicule.findMany({
      select: {
        code_vehicule: true,
        n_immatriculation: true,
        FK_vehicule_REF_type: {
          select: {
            designation: true,
            FK_type_REF_marque: {
              select: {
                designation: true,
              },
            },
          },
        },
        historique_status: {
          take: 1,
          orderBy: {
            date: 'desc',
          },
          select: {
            status: {
              select: {
                designation: true,
              },
            },
          },
        },
        affectations: {
          take: 1,
          orderBy: {
            date: 'desc',
          },
          select: {
            structure: {
              select: {
                designation: true,
              },
            },
          },
        },
        kilo_heure: {
          take: 1,
          orderBy: {
            date: 'desc',
          },
          select: {
            kilo_parcouru_heure_fonctionnement: true,
            date: true,
          },
        },
      },
    });

    console.log('Nombre de véhicules trouvés:', vehicles.length);
    console.log('Premier véhicule:', JSON.stringify(vehicles[0], null, 2));

    // Transformer les données pour correspondre au format attendu par l'application mobile
    const formattedVehicles = vehicles.map((vehicle: any) => ({
      code: vehicle.code_vehicule,
      matricule: vehicle.n_immatriculation,
      marque: vehicle.FK_vehicule_REF_type?.FK_type_REF_marque?.designation || '',
      type: vehicle.FK_vehicule_REF_type?.designation || '',
      statut: vehicle.historique_status?.[0]?.status?.designation || '',
      structure: vehicle.affectations?.[0]?.structure?.designation || 'Non affecté',
      kmTotal: vehicle.kilo_heure?.[0]?.kilo_parcouru_heure_fonctionnement?.toString() || '0',
      derniereMaj: vehicle.kilo_heure?.[0]?.date?.toString() || 'Non disponible',
    }));

    console.log('Véhicules formatés:', JSON.stringify(formattedVehicles[0], null, 2));

    return NextResponse.json(formattedVehicles, { headers: corsHeaders });
  } catch (error) {
    console.error('Erreur détaillée lors de la récupération des véhicules:', error);
    return NextResponse.json(
      { error: `Erreur lors de la récupération des véhicules: ${error.message}` },
      { status: 500, headers: corsHeaders }
    );
  }
} 