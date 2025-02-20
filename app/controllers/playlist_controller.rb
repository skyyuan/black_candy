# frozen_string_literal: true

class PlaylistController < ApplicationController
  include Pagy::Backend

  before_action :require_login
  before_action :find_playlist

  def show
    @pagy, @songs = pagy_countless(@playlist.songs)
  end

  def update
    if @playlist.update(playlist_params)
      case params[:update_action]
      when 'push'
        @song = Song.find(playlist_params[:song_id])
        flash.now[:success] = t('success.add_to_playlist')

        if @playlist.count == 1
          show; render action: 'show'
        end
      when 'delete'
        flash.now[:success] = t('success.delete_from_playlist')

        if @playlist.empty?
          show; render action: 'show'
        end
      end
    end
  end

  def destroy
    @playlist.clear
    @songs = nil
  end

  def play
    raise BlackCandyError::Forbidden if params[:id] == 'current' || @playlist.empty?

    @song_ids = @playlist.song_ids
    Current.user.current_playlist.replace(@song_ids)
  end

  private

    def find_playlist
      case params[:id]
      when 'current'
        @playlist = Current.user.current_playlist
      when 'favorite'
        @playlist = Current.user.favorite_playlist
      else
        @song_collection = Current.user.song_collections.find(params[:id])
        @playlist = @song_collection.playlist
      end
    end

    def playlist_params
      params.permit(:update_action, :song_id)
    end
end
