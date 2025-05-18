import { NextRequest , NextResponse} from "next/server";
import { PrismaClient} from "@prisma/client";
import { Vehicule } from "@/app/interfaces";
import { ajouterVehicule } from "@/app/prisma";

const prisma = new PrismaClient();

export async function GET(req: NextRequest) {
    try {
        const vehicles = await prisma.vehicule.findMany({
            include: {
                type: true,
                genre: true,
                status: {
                    orderBy: {
                        date_status: 'desc'
                    },
                    take: 1
                },
                affectation: {
                    orderBy: {
                        date_affectation: 'desc'
                    },
                    take: 1,
                    include: {
                        structure: true
                    }
                },
                kilometrage_heure: {
                    orderBy: {
                        date_kilometrage_heure: 'desc'
                    },
                    take: 1
                }
            }
        });

        const formattedVehicles = vehicles.map(vehicle => ({
            code: vehicle.code_vehicule,
            matricule: vehicle.n_immatriculation,
            marque: vehicle.genre?.libelle_genre || 'Non défini',
            type: vehicle.type?.libelle_type || 'Non défini',
            statut: vehicle.status[0]?.libelle_status || 'Non défini',
            structure: vehicle.affectation[0]?.structure?.libelle_structure || 'Non défini',
            kmTotal: vehicle.kilometrage_heure[0]?.valeur_kilometrage_heure?.toString() || '0',
            derniereMaj: vehicle.kilometrage_heure[0]?.date_kilometrage_heure?.toLocaleDateString() || 'Non défini'
        }));

        return NextResponse.json(formattedVehicles, { status: 200 });
    } catch (error: any) {
        console.error("Erreur lors de la récupération des véhicules:", error);
        return NextResponse.json({ error: error.message || "Erreur interne du serveur" }, { status: 500 });
    }
}

export async function POST(req: NextRequest) {
    try {
        const contentType = req.headers.get("content-type");
        if (!contentType?.includes("application/json")) {
            return NextResponse.json({ error: "Invalid content type" }, { status: 400 });
        }

        const body = await req.json();
console.log("BODY RECEIVED:", body);

const vehiculeData: Vehicule = body;
console.log("CASTED TO Vehicule:", vehiculeData); 
      


       const ajout = await ajouterVehicule(vehiculeData);
        console.log("Vehicle added successfully:", vehiculeData.code_vehicule);
        return NextResponse.json({ message: "Vehicle bien ajouté" }, { status: 200 });
      ;
    } catch (error: any) {
        console.error("Erreur pendant l'ajout ", error?.message, error?.stack, error);
        return NextResponse.json({ error: error.message || "Internal Server Error" }, { status: 500 });
    }
    
    
}

export async function DELETE(req: NextRequest) {
    try {
      const { code_vehicule } = await req.json()
  
      if (!code_vehicule) {
        return NextResponse.json({ error: "Le code du véhicule est requis" }, { status: 400 })
      }

      await prisma.affectation.deleteMany({
        where: { code_vehicule },
      })
      await prisma.historique_kilometrage_heure.deleteMany({
        where: { code_vehicule },
      })
      await prisma.historique_status.deleteMany({
        where: { code_vehicule },
      })
      await prisma.vehicule.delete({
        where: { code_vehicule },
      })
  
      return NextResponse.json({ message: "Véhicule supprimé avec succès" }, { status: 200 })
    } catch (error) {
      console.error("Error in DELETE /api/vehicule/deleteVehicule", error)
      return NextResponse.json({ error: "Erreur interne du serveur" }, { status: 500 })
    }
  }
  
export async function PUT(req: NextRequest) {
    try {
      const vehiculeData: Vehicule = await req.json()
  
      if (!vehiculeData.code_vehicule) {
        return NextResponse.json({ error: "Le code du véhicule est requis" }, { status: 400 })
      }
  
      // Check if vehicle exists
      const existingVehicule = await prisma.vehicule.findUnique({
        where: { code_vehicule: vehiculeData.code_vehicule },
      })
  
      if (!existingVehicule) {
        return NextResponse.json({ error: "Véhicule non trouvé" }, { status: 404 })
      }
  
      // Update vehicle
      const updatedVehicule = await prisma.vehicule.update({
        where: { code_vehicule: vehiculeData.code_vehicule },
        data: {
          code_type: vehiculeData.code_type,
          code_genre: vehiculeData.code_genre,
          unite_predication: vehiculeData.unite_predication,
          n_immatriculation: vehiculeData.n_immatriculation,
          n_serie: vehiculeData.n_serie,
          date_acquisition: vehiculeData.date_acquisition,
          prix_acquisition: vehiculeData.prix_acquisition,
          n_inventaire: vehiculeData.n_inventaire,
          date_debut_assurance: vehiculeData.date_debut_assurance,
          date_fin_assurance: vehiculeData.date_fin_assurance,
          date_debut_controle_technique: vehiculeData.date_debut_controle_technique,
          date_fin_controle_technique: vehiculeData.date_fin_controle_technique,
          date_debut_atmd: vehiculeData.date_debut_atmd,
          date_fin_atmd: vehiculeData.date_fin_atmd,
          date_debut_permis_circuler: vehiculeData.date_debut_permis_circuler,
          date_fin_permis_circuler: vehiculeData.date_fin_permis_circuler,
          date_debut_certificat: vehiculeData.date_debut_certificat,
          date_fin_certificat: vehiculeData.date_fin_certificat,
        },
      })
  
      return NextResponse.json({ message: "Véhicule mis à jour avec succès", vehicule: updatedVehicule }, { status: 200 })
    } catch (error) {
      console.error("Error in PUT /api/vehicule/updateVehicule", error)
      return NextResponse.json({ error: "Erreur interne du serveur" }, { status: 500 })
    }
  }
  