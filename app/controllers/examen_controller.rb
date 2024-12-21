class ExamenController < ApplicationController
  require 'json'

  before_action :cargar_preguntas, only: [:preguntas, :mostrar_pregunta, :responder]

  def index
  end

  def preguntas
    if params[:cantidad].present?
      cantidad = params[:cantidad] == "todas" ? @preguntas.size : params[:cantidad].to_i
      @preguntas = @preguntas.sample(cantidad) if cantidad > 0
    end

    session[:pregunta_ids] = @preguntas.map { |pregunta| pregunta["id"] }
    session[:indice] = 0
    session[:correctas] = 0
    session[:incorrectas] = 0
    redirect_to action: "mostrar_pregunta"
  end

  def mostrar_pregunta
    @indice = session[:indice]
    if session[:pregunta_ids] && session[:pregunta_ids][@indice]
      @pregunta_actual = @preguntas.find { |pregunta| pregunta["id"] == session[:pregunta_ids][@indice] }
      if @pregunta_actual.nil?
        redirect_to action: "resultado", alert: "No se pudo cargar la pregunta actual."
      end
    else
      redirect_to action: "resultado", alert: "No se pudo cargar la pregunta actual."
    end
  end

  def responder
    @pregunta_actual = @preguntas.find { |pregunta| pregunta["id"] == session[:pregunta_ids][params[:indice].to_i] }
    @respuesta = params[:respuesta]
    @correcta = @pregunta_actual["respuesta_correcta"] == @respuesta

    if @correcta
      session[:correctas] += 1
    else
      session[:incorrectas] += 1
      @respuesta_correcta = @pregunta_actual["respuesta_correcta"]
    end

    respond_to do |format|
      format.html { render :responder }
      format.turbo_stream { render :responder }
    end
  end

  def siguiente
    session[:indice] += 1
    if session[:indice] < session[:pregunta_ids].size
      redirect_to action: "mostrar_pregunta"
    else
      redirect_to action: "resultado"
    end
  end

  def resultado
    @correctas = session[:correctas]
    @incorrectas = session[:incorrectas]
    @total = @correctas + @incorrectas

    respond_to do |format|
      format.html { render :resultado }
      format.turbo_stream { render :resultado }
    end
  end

  private

  def cargar_preguntas
    file = File.read(Rails.root.join('db', 'preguntas.json'))
    @preguntas = JSON.parse(file)
  rescue JSON::ParserError => e
    @preguntas = []
    logger.error "Error al cargar el archivo de preguntas: #{e.message}"
  end
end

def resultado
  @correctas = session[:correctas]
  @incorrectas = session[:incorrectas]
  @total = @correctas + @incorrectas

  respond_to do |format|
    format.html { render :resultado }
    format.turbo_stream { render :resultado }
  end
end
