import requests 
import time
import json
import sys

BASE_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/"

limit = 199  # Limite de IDs por requisição

def busca_ids(specie):
  params = {
    "db": "sra", # Banco de dados pesquisado
    "term": f'({specie}[Organism]) AND "biomol rna"[Properties] AND "rna seq"[Strategy] AND "platform illumina"[Properties] AND "library layout paired"[Properties] AND "filetype fastq"[Properties]', #Filtros
    "retmode": "json",
    "retmax": 1000,  # Pega no máximo 1000 IDs por requisição
    "usehistory": "y"  # Habilita histórico para recuperar todos os IDs
  }

  # Fazendo a requisição inicial para buscar pelos ids 
  response = requests.get(BASE_URL + "esearch.fcgi", params=params)
  if response.status_code == 200:
      data = response.json()
      webenv = data.get("esearchresult", {}).get("webenv")
      query_key = data.get("esearchresult", {}).get("querykey")
      count = int(data.get("esearchresult", {}).get("count", 0))  # Número total de IDs

      if not webenv or not query_key or count == 0:
          print("Nenhum resultado encontrado.")   
      else:
          all_ids = []
          retstart = 0  # Ponto de início para paginação

          while retstart < count:
              print(f"Buscando IDs {retstart + 1} até {min(retstart + 1000, count)} de {count}...")

              params_page = {
                  "db": "sra",
                  "query_key": query_key,
                  "WebEnv": webenv,
                  "retmode": "json",
                  "retmax": 1000,
                  "retstart": retstart
              } 
              response_page = requests.get(BASE_URL + "esearch.fcgi", params=params_page)

              if response_page.status_code == 200:
                  data_page = response_page.json()
                  id_list = data_page.get("esearchresult", {}).get("idlist", [])
                  all_ids.extend(id_list)

                  retstart += 1000  # Avança para o próximo lote

                  time.sleep(1.1)  # Evita sobrecarregar o servidor do NCBI
              else:
                  print(f"Erro ao buscar IDs na página {retstart}: {response_page.status_code}")
                  break  # Interrompe a busca se houver erro
  return all_ids
  
if __name__ == "__main__":
    specie = sys.argv[1]
    ids = busca_ids(specie)
    with open("ids.json", "w", encoding="utf-8") as f:
        json.dump(ids, f, ensure_ascii=False, indent=4)

