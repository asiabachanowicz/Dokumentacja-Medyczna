import shutil

from django.shortcuts import render, redirect
from django.http import JsonResponse
from .models import Pacjent
from .models import Lekarz

from django.core import serializers
from django.views.generic import ListView
import json

from django.http import HttpResponse

from lxml import etree
import os
import sys
import pandas as pd
from bs4 import BeautifulSoup
from lxml import etree
import pdfkit
import os
import sys
import pandas as pd
from bs4 import BeautifulSoup

import os
import glob

from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from django.conf import settings

def index(request):
    return render(request,"index.html")

def patientSite(request):
    print(request)
    badania_lab = []
    badania_mri = []
    diagnozy = []
    patient_name = (request.GET["id"]).split("-")[0]
    patient_surname = (request.GET["id"]).split("-")[1]
    print(patient_name)
    print(patient_surname)
    patient1 = Pacjent.objects.all().filter(imie=patient_name).filter(nazwisko=patient_surname)
    print(patient1)
    badania_mri_1 = glob.glob("templates\\data\\badania_mri\\*.xml")
    badania_lab_1 = glob.glob("templates\\data\\badania_lab\\*.xml")
    diagnozy_1 = glob.glob("templates\\data\\diagnozy\\*.xml")

    for b in badania_mri_1:
        if patient1[0].pesel in b:
            b = str(b).replace("templates\\", "")
            badania_mri.append(b)

    for b in badania_lab_1:
        if patient1[0].pesel in b:
            b = str(b).replace("templates\\", "")
            badania_lab.append(b)

    for b in diagnozy_1:
        if patient1[0].pesel in b:
            b = str(b).replace("templates\\", "")
            diagnozy.append(b)

    print(badania_lab)

    return render(request, "patientSite.html", {"pac": patient1, "badania_mri": badania_mri, "badania_lab": badania_lab, "diagnozy": diagnozy})

def pdf_f(adres):
    print("adres")
    print(adres)
    output_pdf = pdfkit.from_file("templates/" + adres, "out.pdf")

def csv_f(adres):
    import winreg
    sub_key = r'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders'
    downloads_guid = '{374DE290-123F-4565-9164-39C4925E467B}'
    with winreg.OpenKey(winreg.HKEY_CURRENT_USER, sub_key) as key:
        location = winreg.QueryValueEx(key, downloads_guid)[0]

    print("csv")
    print(adres)
    # convert html to csv
    data = []
    # for getting the header from the HTML file
    list_header = []
    soup = BeautifulSoup(open("templates/" + adres),'html.parser')
    header = soup.find_all("table")[0].find("tr")
    for items in header:
        try:
            list_header.append(items.get_text())
        except:
            continue

    # for getting the data
    HTML_data = soup.find_all("table")[0].find_all("tr")[1:]

    for element in HTML_data:
        sub_data = []
        for sub_element in element:
            try:
                sub_data.append(sub_element.get_text())
            except:
                continue
        data.append(sub_data)

    # Storing the data into Pandas DataFrame
    dataFrame = pd.DataFrame(data = data, columns = list_header)

    # Converting Pandas DataFrame into CSV file
    adres = str(adres).split("/")[2].replace(".html", ".csv")
    print(adres)

    dst = location
    shutil.move(adres, dst)
    dataFrame.to_csv(adres)

def badaniaMri(request):
    print(request)
    csv = False
    pdf = False
    if "pdf" in str(request):
        pdf = True
    elif "csv" in str(request):
        csv = True
    adres = str(request).split("/data/badania_lab")[2]
    adres = "data/badania_lab" + adres
    adres = adres[:-1]
    adres = adres[:-1]
    files = os.listdir(os.curdir)
    print(files)
    xslt_doc = etree.parse("templates/data/badania_mri/schema_mri.xsl")
    xslt_transformer = etree.XSLT(xslt_doc)

    source_doc = etree.parse("templates/" + adres)
    output_doc = xslt_transformer(source_doc)
    adres = str(adres).replace("badanie_mri", "output")
    adres = str(adres).replace(".xml", ".html")

    output_doc.write("templates/" + adres, pretty_print=True)
    if pdf:
        pdf_f(adres)
    if csv:
        csv_f(adres)
    return render(request, adres)

def badaniaLab(request):
    print(request)
    csv = False
    pdf = False
    if "pdf" in str(request):
        pdf = True
    elif "csv" in str(request):
        csv = True
    adres = str(request).split("/data/badania_lab")[2]
    adres = "data/badania_lab" + adres
    adres = adres[:-1]
    adres = adres[:-1]

    files = os.listdir(os.curdir)
    xslt_doc = etree.parse("templates/data/badania_lab/schema_lab.xsl")
    xslt_transformer = etree.XSLT(xslt_doc)

    source_doc = etree.parse("templates/" + adres)
    output_doc = xslt_transformer(source_doc)
    adres = str(adres).replace("badanie_lab", "output")
    adres = str(adres).replace(".xml", ".html")

    output_doc.write("templates/" + adres, pretty_print=True)
    if pdf:
        pdf_f(adres)
    if csv:
        csv_f(adres)
    print(adres)
    return render(request, adres)

def diagnozy(request):
    print(request)
    csv = False
    pdf = False
    if "pdf" in str(request):
        pdf = True
    elif "csv" in str(request):
        csv = True
    adres = str(request).split("/data/badania_lab")[2]
    adres = "data/badania_lab" + adres
    adres = adres[:-1]
    adres = adres[:-1]
    files = os.listdir(os.curdir)
    print(files)
    xslt_doc = etree.parse("templates/data/diagnozy/schema_diagnoza.xsl")
    xslt_transformer = etree.XSLT(xslt_doc)

    source_doc = etree.parse("templates/"+adres)
    output_doc = xslt_transformer(source_doc)
    adres = str(adres).replace("diagnoza", "output")
    adres = str(adres).replace(".xml", ".html")

    output_doc.write("templates/"+adres, pretty_print=True)
    if pdf:
        pdf_f(adres)
    if csv:
        csv_f(adres)
    return render(request, adres)


def loginPatient(request):
    if request.method == 'POST':
        Pacjent.objects
        patient = Pacjent.objects.all().filter(login=request.POST["login"], haslo=request.POST['password'])
        print(patient)
        if patient.exists():
            print("zalogowano pacjenta")
            badania_lab = []
            badania_mri = []
            diagnozy = []
            badania_mri_1 = glob.glob("templates\\data\\badania_mri\\*.xml")
            badania_lab_1 = glob.glob("templates\\data\\badania_lab\\*.xml")
            diagnozy_1 = glob.glob("templates\\data\\diagnozy\\*.xml")

            for b in badania_mri_1:
                if patient[0].pesel in b:
                    b = str(b).replace("templates\\", "")
                    badania_mri.append(b)

            for b in badania_lab_1:
                if patient[0].pesel in b:
                    b = str(b).replace("templates\\", "")
                    badania_lab.append(b)

            for b in diagnozy_1:
                if patient[0].pesel in b:
                    b = str(b).replace("templates\\", "")
                    diagnozy.append(b)
            return render(request, 'patient.html', {"pac": patient, "badania_mri": badania_mri, "badania_lab": badania_lab, "diagnozy": diagnozy})
        else:
            print("nie udalo sie zalogowac pacjenta")
    return render(request,'loginPatient.html')

def addDocument(request):
    print("funkcja")
    if request.method == "POST" or request.is_ajax():
        print("test1")
        file = request.FILES.get('file')
        print(file)
        print("test2")
        badania_mri_1 = glob.glob("templates\\data\\badania_mri\\*.xml")
        badania_lab_1 = glob.glob("templates\\data\\badania_lab\\*.xml")
        diagnozy_1 = glob.glob("templates\\data\\diagnozy\\*.xml")
        if request.POST["path"] == "badania_lab":
            if file.name in badania_lab_1:
                print("tak")
                return render(request, 'addDocument.html')
            if "lab" not in file.name:
                print("tak")
                return render(request, 'addDocument.html')
            path = default_storage.save('templates/data/badania_lab/' + file.name, ContentFile(file.read()))
        if request.POST["path"] == "badania_mri":
            if file.name in badania_mri_1:
                return render(request, 'addDocument.html')
            if "mri" not in file.name:
                print("tak")
                return render(request, 'addDocument.html')
            path = default_storage.save('templates/data/badania_mri/' + file.name, ContentFile(file.read()))
        if request.POST["path"] == "diagnozy":
            if file.name in diagnozy_1:
                return render(request, 'addDocument.html')
            if "diag" not in file.name:
                print("tak")
                return render(request, 'addDocument.html')
            path = default_storage.save('templates/data/diagnozy/' + file.name, ContentFile(file.read()))
    if request.method == "GET":
        id = request.GET["id"]
        name = str(id).split("-")[0]
        surname = str(id).split("-")[1]

        patient1 = Pacjent.objects.all().filter(imie=name).filter(nazwisko=surname)
        print(patient1)

    return render(request, 'addDocument.html')

def report(request):
    pesel = (request.GET["pesel"])
    string1 = ("templates/data/badania_lab/output_" + pesel + "_1.html")
    string2  = ("templates/data/badania_lab/output_" + pesel + "_2.html")

    firsts = []
    seconds = []
    b="&#181;"

    file1 = open(string1, "r")
    file2 = open(string2, "r")

    with file1, file2:
        for file1Line, file2Line in zip(file1, file2):
            if file1Line != file2Line:
                print("file1"+file1Line.strip('\n'))
                print("file2"+file2Line.strip('\n'))
                firsts.append(file1Line)
                seconds.append(file2Line)
    firsts = [w.replace('<td>', ' ') for w in firsts]
    seconds = [w.replace('<td>', ' ') for w in seconds]
    firsts = [w.replace('</td>', ' ') for w in firsts]
    seconds = [w.replace('</td>', ' ') for w in seconds]
    firsts = [w.replace('&#181;', '\u03BC') for w in firsts]
    seconds = [w.replace('&#181;', '\u03BC') for w in seconds]

    return render(request, 'report.html', {'firsts':firsts, 'seconds':seconds})

def registerPatient(request):
    if request.method == 'POST':
        mail = request.POST['login']
        name = request.POST['name']
        password = request.POST['password']
        surname = request.POST['surname']
        address = request.POST['address']
        peselP = request.POST['peselP']
        date_birth = request.POST['birth_date']
        print(name, password)
        sex = request.POST['sex']
        if sex == 'women':
            plec="kobieta"
        if sex == 'men':
            plec = "mezczyzna"

        patient = Pacjent.objects.create(haslo=password, login=mail, imie=name, nazwisko=surname, adres=address, pesel=peselP, plec=plec, data_ur=date_birth)
        print(patient)
        patient.save()
        return render(request, 'loginPatient.html')
    return render(request,'registerPatient.html')

def patient(request):
    return render(request, 'patient.html')


def loginDoctor(request):
    if request.method == 'POST':
        Lekarz.objects
        login = Lekarz(login="test")
        doctors = Lekarz.objects.all().filter(login=request.POST["login"], haslo=request.POST['password'])
        print(doctors)
        if doctors.exists():
            print("zalogowano lekarza")
            return redirect('doctor')
        else:
            print("nie udalo sie zalogowac lekarza")
    return render(request,'loginDoctor.html')

def registerDoctor(request):
    if request.method == 'POST':
        mail = request.POST['login']
        password = request.POST['password']
        name = request.POST['name']
        surname = request.POST['surname']
        tel_number = request.POST['tel_number']
        print(name, password)

        doctor = Lekarz.objects.create(haslo=password, login=mail, imie=name, nazwisko=surname, nr_telefonu=tel_number)
        print(doctor)
        doctor.save()
        return render(request, 'loginDoctor.html')
    return render(request,'registerDoctor.html')

def doctor(request):
    if request.method == 'POST' or request.is_ajax():
        Pacjent.objects
        patient_data = request.POST['text']
        patient1 = Pacjent.objects.all().filter(imie__startswith=patient_data)
        patient2 = Pacjent.objects.all().filter(pesel__startswith=patient_data)
        patient3 = Pacjent.objects.all().filter(nazwisko__startswith=patient_data)
        if patient1.exists():
            print(patient_data)
            print(patient1)
            serialized_qs = serializers.serialize('json', patient1)
            return JsonResponse(serialized_qs, safe=False)
        elif patient2.exists():
            print(patient_data)
            print(patient2)
            serialized_qs = serializers.serialize('json', patient2)
            return JsonResponse(serialized_qs, safe=False)
        elif patient3.exists():
            print(patient_data)
            print(patient3)
            serialized_qs = serializers.serialize('json', patient3)
            return JsonResponse(serialized_qs, safe=False)
        patients = Pacjent.objects.all().filter(nazwisko__startswith=patient_data)
        if patients.exists():
            print(patient_data)
            print(patients)
            return HttpResponse(patients)

    pac = Pacjent.objects.all()

    return render(request,"doctor.html", {'pac':pac})