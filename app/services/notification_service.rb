# Service for handling notification logic
class NotificationService
  class << self
    # Create a notification
    def create_notification(user:, title:, message:, notification_type: 'info')
      # Determine polymorphic association
      if user.is_a?(Employee)
        notifiable_type = 'Employee'
        company_id = user.company_id
      elsif user.is_a?(Profile)
        notifiable_type = 'Profile'
        company_id = user.company_id
      else
        return { success: false, error: 'Invalid user type' }
      end

      notification = Notification.create(
        company_id: company_id,
        notifiable_type: notifiable_type,
        notifiable_id: user.id,
        title: title,
        message: message,
        notification_type: notification_type,
        is_read: false
      )

      if notification.persisted?
        { success: true, notification: notification }
      else
        { success: false, errors: notification.errors.full_messages }
      end
    end

    # Mark notification as read
    def mark_as_read(notification)
      notification.update(is_read: true, read_at: Time.current)
    end

    # Mark all notifications as read for a user
    def mark_all_as_read(user)
      notifications = get_user_notifications(user)
      notifications.update_all(is_read: true, read_at: Time.current)
    end

    # Get unread count
    def unread_count(user)
      get_user_notifications(user).where(is_read: false).count
    end

    # Get user notifications
    def get_user_notifications(user, limit: 50)
      if user.is_a?(Employee)
        Notification.where(notifiable_type: 'Employee', notifiable_id: user.id)
                   .order(created_at: :desc)
                   .limit(limit)
      elsif user.is_a?(Profile)
        Notification.where(notifiable_type: 'Profile', notifiable_id: user.id)
                   .order(created_at: :desc)
                   .limit(limit)
      else
        Notification.none
      end
    end
  end
end
