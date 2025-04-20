import requests
import xml.etree.ElementTree as ET
import re
from Bio import Entrez
import json
import sys

def bioproject_uid(bioproject_id):

    Entrez.email = "teste@gmail.com"

    # Accession do BioProject que queremos buscar
    accession = bioproject_id

    # Passo 1: Buscar o ID do BioProject pelo Accession
    search_handle = Entrez.esearch(db="bioproject", term=accession)
    search_results = Entrez.read(search_handle)
    search_handle.close()

    # Verificar se encontrou algum ID
    if search_results["IdList"]:
        bioproject_uid = search_results["IdList"][0]  # Pegando o primeiro UID da lista
        
    else:
        print("Nenhum resultado encontrado para o Accession:", accession)

    return Bioproject_info(bioproject_id,bioproject_uid)


def Bioproject_info(id,uid):
    BASE_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi"

    dados = {
            "bioproject_uid":uid,
            "bioproject_id":id,
            "título": "nao encontrado",
            "descrição": "nao encontrado",
        }


    params_bioproject = {
        "db": "bioproject",
        "id": uid,
        "retmode": "xml"
    }

    response = requests.get(BASE_URL, params=params_bioproject)

    if response.status_code == 200:
        bioproject_data = response.text
        root = ET.fromstring(bioproject_data)

        for docsum in root.findall(".//DocumentSummary"):
            project_title = docsum.findtext("Project_Title", "N/A")
            project_description = docsum.findtext("Project_Description", "N/A")
        
            dados["título"] = project_title
            dados["descrição"] = project_description

            
    else:
        print(f"⚠️ Erro ao buscar ID {id}: {response.status_code}")

    if not dados :
        print(f"ERRO dado nao coletado do projeto {id}")
    return dados

if __name__ == "__main__":
    infile = sys.argv[1]
    outfile = sys.argv[2]
    with open(infile,'r',encoding='utf-8') as f:
        ids = json.load(f)
        projs = {item['bioproject'] for item in ids}
    out = [bioproject_uid(pid) for pid in projs]
    with open(outfile,'w',encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, indent=4)