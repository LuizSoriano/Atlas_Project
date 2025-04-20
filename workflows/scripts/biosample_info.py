from Bio import Entrez
import xml.etree.ElementTree as ET
import json
import sys

# Definir o e-mail (opcional, mas recomendado pela NCBI)
Entrez.email = "seu-email@exemplo.com"
LIMIT = 199  # Número máximo de requisições por lote

def chunk_list(data, size):
    """Divide uma lista em sublistas de tamanho 'size'"""
    data = list(data)  # ✅ Converte para lista, caso seja um set
    return [data[i:i + size] for i in range(0, len(data), size)]

def get_uids_from_accessions(accessions):
    """Obtém UIDs para uma lista de Accession Numbers, dividindo em lotes de 199"""
    accessions = list(accessions)  # ✅ Converte para lista se necessário
    uids = []

    # Divide os accession numbers em lotes de no máximo 199
    accession_batches = chunk_list(accessions, LIMIT)

    for batch in accession_batches:
        term_query = " OR ".join([f"{acc}[ACCN]" for acc in batch])  # Monta a query
        handle = Entrez.esearch(db="biosample", term=term_query, retmax=LIMIT)
        record = Entrez.read(handle)
        handle.close()

        uids.extend(record["IdList"])  # Adiciona os UIDs encontrados
    
    return list(uids)  # ✅ Garante que seja uma lista

def Biosample_info(accessions):
    """Busca informações detalhadas de BioSamples, dividindo em lotes de 199"""
    accessions = list(accessions)  # ✅ Converte para lista se necessário
    uids = get_uids_from_accessions(accessions)

    if not uids:
        print("Nenhum UID encontrado para os BioSamples fornecidos.")
        return []

    dados = []

    # Divide os UIDs em lotes de no máximo 199 antes de chamar `esummary`
    uid_batches = chunk_list(uids, LIMIT)

    for batch in uid_batches:
        handle = Entrez.esummary(db="biosample", id=",".join(batch), retmode="xml")
        xml_data = handle.read()
        handle.close()

        root = ET.fromstring(xml_data)

        for docsum in root.findall(".//DocumentSummary"):
            accession = docsum.findtext("Accession", "N/A")
            title = docsum.findtext("Title", "N/A")

            info = {"biosample_id": accession, "titulo": title}

            # Extraindo atributos adicionais se disponíveis
            sample_data = docsum.find("SampleData")
            if sample_data is not None:
                for attribute in ET.fromstring(sample_data.text).findall(".//Attribute"):
                    name = attribute.get("attribute_name", "Desconhecido")
                    value = attribute.text
                    info[name] = value 

            dados.append(info)

    return dados

if __name__ == "__main__":
    infile = sys.argv[1]
    outfile = sys.argv[2]
    with open(infile,'r',encoding='utf-8') as f:
        ids = json.load(f)
        bios = {item['biosample'] for item in ids}
    data = Biosample_info(bios)
    with open(outfile,'w',encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)