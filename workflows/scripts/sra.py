import xml.etree.ElementTree as ET
from collections import defaultdict
import requests
import time
import re
import json
import sys

BASE_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/"

def extract_xml_data(xml_string):
    try:
        xml_string = xml_string.strip()
        if not xml_string.startswith("<Root>"):
            xml_string = f"<Root>{xml_string}</Root>"
        xml_string = re.sub(r">\s+<", "><", xml_string)
        
        root = ET.fromstring(xml_string)
        data = {}
        
        data['BioProject'] = root.findtext('.//Bioproject', "N/A")
        data['Biosample'] = root.findtext('.//Biosample', "N/A")
        data['Run'] = root.find('.//Run').attrib.get('acc', "N/A") if root.find('.//Run') is not None else "N/A"
        
        return data
    except ET.ParseError as e:
        print(f"Erro ao analisar o XML: {e}")
        return {
            "BioProject": "N/A",
            "SampleName": "N/A", "Biosample": "N/A", "Run": "N/A"
        }

def extract_run_acc(xml_string):
    try:
        # Envolver o XML em uma única raiz para evitar erro de múltiplos elementos raiz
        wrapped_xml = f"<root>{xml_string}</root>"
        root = ET.fromstring(wrapped_xml)

        # Coletar todos os valores de "acc" dos elementos <Run>
        run_accs = [run.attrib.get("acc", "N/A") for run in root.findall("Run")]
        
        return run_accs  # Retorna um vetor com todas as RUNs encontradas

    except ET.ParseError as e:
        print(xml_string)
        print(f"Erro ao analisar o XML: {e}")
        return []

def sra_info(all_ids):
  limit = 199
  ids = []
  
  for i in range(0, len(all_ids), limit):
    
    limit_ids = all_ids[i:i + limit]  # Pega um subconjunto de IDs  

    sra_ids = ",".join(limit_ids)  # Junta os IDs em uma string separada por vírgulas
    params_summary = {
    "db": "sra",
    "id": sra_ids,
    "retmode": "xml"  # Usando XML diretamente, pois a API retorna XML
    }
    summary_response = requests.get(BASE_URL + "esummary.fcgi", params=params_summary)

    print(f"Resposta dos (IDs {i} a { min(i + limit,len(all_ids))}): {summary_response.status_code}")

    if summary_response.status_code == 200:
      summary_data = summary_response.text  # Pega a resposta como XML
      
      root = ET.fromstring(summary_data)  # Converte para ElementTree

      for docsum in root.findall(".//DocSum"):
        exp_xml = docsum.find(".//Item[@Name='ExpXml']").text
        run_xml = docsum.find(".//Item[@Name='Runs']").text
        

        exp_data = extract_xml_data(exp_xml) if exp_xml else {}
        run_data = extract_run_acc(run_xml) if exp_xml else {}
        

        dados = {
           "run":"nao encontrado",
           "biosample":"nao encontrado",
           "bioproject":"nao encontrado"
        }
        run = exp_data.get("Run", None),
        bioproject = exp_data.get("BioProject", None)
        biosample = exp_data.get("Biosample", None)
        if biosample:  
          dados["biosample"] = biosample  # Adiciona o Biosample ao dicionario
        if bioproject:
          dados["bioproject"] = bioproject # Adiciona o Bioproject ao dicionario
        if run:
           dados["run"] = run_data # Adiciona a run ao dicionario
        ids.append(dados)   

      time.sleep(1.1)
    else:
      print(f"Erro ao obter detalhes (IDs {i} a {i + limit}): {summary_response.status_code}")
  
  return ids

if __name__ == "__main__":
  infile = sys.argv[1]
  outfile = sys.argv[2]
  with open(infile,'r',encoding='utf-8') as f:
    all_ids = json.load(f)
  result = sra_info(all_ids)
  with open(outfile,'w',encoding='utf-8') as f:
    json.dump(result, f, ensure_ascii=False, indent=4)