import { v } from "convex/values";
import { mutation, query } from "./_generated/server";
import { Doc, Id } from "./_generated/dataModel";

// Send a message to a conversation
export const sendMessage = mutation({
  args: {
    conversationId: v.id("conversations"),
    senderId: v.id("users"),
    content: v.string(),
    type: v.optional(v.union(
      v.literal("text"),
      v.literal("image"),
      v.literal("offer"),
      v.literal("system")
    )),
    metadata: v.optional(v.object({
      offerAmount: v.optional(v.number()),
      imageUrl: v.optional(v.string()),
      systemType: v.optional(v.string()),
    })),
  },
  handler: async (ctx, args) => {
    const messageId = await ctx.db.insert("messages", {
      conversationId: args.conversationId,
      senderId: args.senderId,
      content: args.content,
      type: args.type || "text",
      metadata: args.metadata,
      isRead: false,
      createdAt: Date.now(),
    });

    // Update conversation's last message
    await ctx.db.patch(args.conversationId, {
      lastMessage: args.content,
      lastMessageTime: Date.now(),
    });

    return messageId;
  },
});

// Get messages for a conversation
export const getMessages = query({
  args: {
    conversationId: v.id("conversations"),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const messages = await ctx.db
      .query("messages")
      .withIndex("by_conversation", (q) =>
        q.eq("conversationId", args.conversationId)
      )
      .order("desc")
      .take(args.limit || 50);

    // Get sender information for each message
    const messagesWithSenders = await Promise.all(
      messages.map(async (message) => {
        const sender = await ctx.db.get(message.senderId);
        return {
          ...message,
          sender,
        };
      })
    );

    return messagesWithSenders.reverse();
  },
});

// Mark messages as read
export const markMessagesAsRead = mutation({
  args: {
    conversationId: v.id("conversations"),
    userId: v.id("users"),
  },
  handler: async (ctx, args) => {
    const messages = await ctx.db
      .query("messages")
      .withIndex("by_conversation_unread", (q) =>
        q.eq("conversationId", args.conversationId).eq("isRead", false)
      )
      .collect();

    // Mark all unread messages not from the current user as read
    for (const message of messages) {
      if (message.senderId !== args.userId) {
        await ctx.db.patch(message._id, { isRead: true });
      }
    }
  },
});

// Get unread message count for a user
export const getUnreadCount = query({
  args: {
    userId: v.id("users"),
  },
  handler: async (ctx, args) => {
    // Get all conversations where user is a participant
    const conversations = await ctx.db
      .query("conversations")
      .filter((q) =>
        q.or(
          q.eq(q.field("sellerId"), args.userId),
          q.eq(q.field("buyerId"), args.userId)
        )
      )
      .collect();

    let totalUnread = 0;

    for (const conversation of conversations) {
      const unreadMessages = await ctx.db
        .query("messages")
        .withIndex("by_conversation_unread", (q) =>
          q.eq("conversationId", conversation._id).eq("isRead", false)
        )
        .filter((q) => q.neq(q.field("senderId"), args.userId))
        .collect();

      totalUnread += unreadMessages.length;
    }

    return totalUnread;
  },
});

// Set typing indicator
export const setTyping = mutation({
  args: {
    conversationId: v.id("conversations"),
    userId: v.id("users"),
    isTyping: v.boolean(),
  },
  handler: async (ctx, args) => {
    const existing = await ctx.db
      .query("typing")
      .withIndex("by_conversation", (q) =>
        q.eq("conversationId", args.conversationId)
      )
      .filter((q) => q.eq(q.field("userId"), args.userId))
      .first();

    if (args.isTyping) {
      if (existing) {
        await ctx.db.patch(existing._id, { timestamp: Date.now() });
      } else {
        await ctx.db.insert("typing", {
          conversationId: args.conversationId,
          userId: args.userId,
          timestamp: Date.now(),
        });
      }
    } else if (existing) {
      await ctx.db.delete(existing._id);
    }
  },
});

// Get typing indicators for a conversation
export const getTypingUsers = query({
  args: {
    conversationId: v.id("conversations"),
    currentUserId: v.id("users"),
  },
  handler: async (ctx, args) => {
    const typingRecords = await ctx.db
      .query("typing")
      .withIndex("by_conversation", (q) =>
        q.eq("conversationId", args.conversationId)
      )
      .filter((q) => q.neq(q.field("userId"), args.currentUserId))
      .collect();

    // Filter out stale typing indicators (older than 5 seconds)
    const activeTyping = typingRecords.filter(
      (record) => Date.now() - record.timestamp < 5000
    );

    // Get user information for active typing users
    const typingUsers = await Promise.all(
      activeTyping.map(async (record) => {
        const user = await ctx.db.get(record.userId);
        return user;
      })
    );

    return typingUsers.filter(Boolean);
  },
});