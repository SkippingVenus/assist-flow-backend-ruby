# Notifications Controller
module Api
  module V1
    class NotificationsController < BaseController
      # GET /api/v1/notifications
      def index
        if current_user_type == 'admin'
          notifications = current_user.notifications
        else
          notifications = current_user.notifications
        end
        
        notifications = notifications.includes(:employee)
        
        if params[:is_read] == 'false'
          notifications = notifications.unread
        elsif params[:is_read] == 'true'
          notifications = notifications.where(is_read: true)
        end
        
        if params[:notification_type]
          notifications = notifications.by_type(params[:notification_type])
        end
        
        notifications = notifications.order(created_at: :desc).limit(params[:limit] || 50)
        
        render_success(notifications)
      end
      
      # GET /api/v1/notifications/unread_count
      def unread_count
        count = if current_user_type == 'admin'
          current_user.notifications.unread.count
        else
          current_user.notifications.unread.count
        end
        
        render_success({ unread_count: count })
      end
      
      # POST /api/v1/notifications/:id/mark_read
      def mark_read
        notification = Notification.find(params[:id])
        
        # Check permissions
        if current_user_type == 'admin' && notification.recipient_type != 'Profile'
          return render_forbidden
        end
        
        if current_user_type == 'employee' && notification.recipient_id != current_user.id
          return render_forbidden
        end
        
        notification.update(is_read: true)
        render_success({ message: 'Notificación marcada como leída' })
      end
      
      # POST /api/v1/notifications/mark_all_read
      def mark_all_read
        notifications = if current_user_type == 'admin'
          current_user.notifications
        else
          current_user.notifications
        end
        
        notifications.unread.update_all(is_read: true)
        
        render_success({ message: 'Todas las notificaciones marcadas como leídas' })
      end
      
      # DELETE /api/v1/notifications/:id
      def destroy
        notification = Notification.find(params[:id])
        
        # Check permissions
        if current_user_type == 'admin' && notification.recipient_type != 'Profile'
          return render_forbidden
        end
        
        if current_user_type == 'employee' && notification.recipient_id != current_user.id
          return render_forbidden
        end
        
        notification.destroy
        render_success({ message: 'Notificación eliminada' })
      end
    end
  end
end
