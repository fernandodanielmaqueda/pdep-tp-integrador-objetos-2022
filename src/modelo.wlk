class NoPuedePrepararRecetaException inherits DomainException {}

class Academia{
    const property estudiantes
    const property recetario

    method entrenarEstudiantes(){
        self.estudiantes().forEach({estudiante => estudiante.entrenar(recetario)})
    }
}

class Cocinero{
    var property comidasPreparadas = []
    var property nivelActual = principiante

    method nivelExperiencia() =  self.comidasPreparadas().sum({comida => comida.experienciaAportada()}) 

    method superaNivel(nivel) = nivel.superaNivel(self)

    method puedePreparar(receta) = not receta.esDificil() or self.nivelActual().puedePreparar(receta, self)

    method prepararComida(receta){
        if(not self.puedePreparar(receta)){
            throw new NoPuedePrepararRecetaException(message = "El cocinero todavia no puede preparar esta receta")
        }
        comidasPreparadas.add(new Comida(calidad = self.nivelActual().calidadComidaPreparada(receta, self), receta = receta))
        self.cambiarDeNivelSiSuperaNivelActual()
    }

    method cambiarDeNivelSiSuperaNivelActual(){
        if(self.superaNivel(nivelActual)){
            self.nivelActual(nivelActual.siguienteNivel())
        }
    }

    method cantidadDeComidasConRecetasSimilares(receta) = self.comidasConRecetasSimilares(receta).size()

    method comidasConRecetasSimilares(receta) = self.comidasPreparadas().filter({comida => comida.receta().esSimilar(receta)})

    method logroPerfeccionar(receta) = self.comidasConRecetasSimilares(receta).sum({comida => comida.experienciaAportada()}) >= receta.experienciaRequeridaParaPerfeccionar()

    method entrenar(recetario){
        const laRecetaAPreparar= self.recetasQuePuedePreparar(recetario).max({receta => receta.experienciaAportadaNormalmente()})
        self.prepararComida(laRecetaAPreparar)
    }

    method recetasQuePuedePreparar(recetario) = recetario.filter({receta => self.puedePreparar(receta)})
    
    method esSimilarAAlgunaQuePreparo(receta) = self.comidasPreparadas().any({comida => comida.receta().esSimilar(receta)})
    
    method preparoMasDe5ComidasDificiles() = self.comidasPreparadas().filter({comida => comida.receta().esDificil()}).size() > 5 
}

class Comida{
    const property calidad
    const property receta

    method experienciaAportada() = calidad.experienciaAportada(receta)
}

class Receta{
    const property nivelDificultad
    const property ingredientes = #{}

    method cantidadIngredientes() = self.ingredientes().size() 

    method experienciaAportadaNormalmente(){
        return self.cantidadIngredientes() * self.nivelDificultad()
    }

    method esDificil() = nivelDificultad > 5 or self.cantidadIngredientes() > 10

    method esSimilar(otraReceta) = self.tieneMismosIngredientes(otraReceta) or self.dificultadSimilar(otraReceta)

    method tieneMismosIngredientes(receta) = self.ingredientes() == receta.ingredientes()

    method dificultadSimilar(receta) = (self.nivelDificultad() - receta.nivelDificultad()).abs() <= 1
    
    method experienciaRequeridaParaPerfeccionar() = self.experienciaAportadaNormalmente() * 3
}

class RecetaGourmet inherits Receta{
    override method experienciaAportadaNormalmente() = super() * 2

    override method esDificil() = true
}

object pobre{
    var property experienciaMaxima = 0

    method experienciaAportada(receta) = receta.experienciaAportadaNormalmente().min(self.experienciaMaxima())
}

object normal{
    method experienciaAportada(receta) = receta.experienciaAportadaNormalmente() 
}

class Superior{
    const property plus

    method experienciaAportada(receta) = receta.experienciaAportadaNormalmente() + self.plus()
}

object principiante{
    method siguienteNivel() = new Experimentado()

    method superaNivel(cocinero) = cocinero.nivelExperiencia() > 100

    method puedePreparar(receta, cocinero) = false

    method calidadComidaPreparada(receta, cocinero){
        if(receta.cantidadIngredientes() < 4){
            return normal
        }else{
            return pobre
        }
    }
}

class Experimentado {
    method siguienteNivel() = chef

    method puedePreparar(receta, cocinero) = cocinero.esSimilarAAlgunaQuePreparo(receta)

    method superaNivel(cocinero) = cocinero.preparoMasDe5ComidasDificiles()

    method calidadComidaPreparada(receta, cocinero){
       if(cocinero.logroPerfeccionar(receta)){           
            return new Superior(plus = cocinero.cantidadDeComidasConRecetasSimilares(receta) / 10)
        }else{
            return normal
        }
    }
}

object chef inherits Experimentado{
    // Por como esta definido el tp, nunca superaria en nivel chef entonces nunca necesitaria saber el siguienteNivel.
    // Sin embargo, se define metodo por cuestiones de polimorfismo.
    override method siguienteNivel() = self

    override method puedePreparar(receta, cocinero) = true
    
    override method superaNivel(cocinero) = false

}