from django.db import models

# Create your models here.

class Pacjent(models.Model):
    pacjentID = models.CharField(max_length=30)
    haslo = models.CharField(max_length=30)
    login = models.CharField(max_length=30)
    imie = models.CharField(max_length=30)
    nazwisko = models.CharField(max_length=30)
    adres = models.TextField(max_length=30)
    rodzaj_choroby = models.CharField(max_length=30)
    nazwa_badania = models.CharField(max_length=30)
    plec = models.CharField(max_length=30)
    data_ur = models.DateField(max_length=30)

class Lekarz(models.Model):
    doctorID = models.CharField(max_length=30)
    haslo = models.CharField(max_length=30)
    login = models.CharField(max_length=30)
    imie = models.CharField(max_length=30)
    nazwisko = models.CharField(max_length=30)
    nr_telefonu = models.CharField(max_length=30)