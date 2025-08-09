import { v } from "convex/values";
import { mutation, query } from "./_generated/server";
import { Doc, Id } from "./_generated/dataModel";

// Create or get a conversation between buyer and seller for an item
export const createOrGetConversation = mutation({
  args: {
    sellerId: v.id("users"),
    buyerId: v.id("users"),
    itemId: v.string(),
    itemTitle: v.string(),
    itemPrice: v.number(),
    itemImage: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    // Check if conversation already exists for this item between these users
    const existing = await ctx.db
      .query("conversations")
      .withIndex("by_item", (q) => q.eq("itemId", args.itemId))
      .filter((q) =>
        q.and(
          q.eq(q.field("sellerId"), args.sellerId),
          q.eq(q.field("buyerId"), args.buyerId)
        )
      )
      .first();

    if (existing) {
      return existing._id;
    }

    // Create new conversation
    const conversationId = await ctx.db.insert("conversations", {
      participants: [args.sellerId, args.buyerId],
      itemId: args.itemId,
      itemTitle: args.itemTitle,
      itemPrice: args.itemPrice,
      itemImage: args.itemImage,
      sellerId: args.sellerId,
      buyerId: args.buyerId,
      createdAt: Date.now(),
      status: "active",
    });

    // Create initial system message
    await ctx.db.insert("messages", {
      conversationId,
      senderId: args.buyerId,
      content: `Started a conversation about ${args.itemTitle}`,
      type: "system",
      metadata: {
        systemType: "conversation_started",
      },
      isRead: false,
      createdAt: Date.now(),
    });

    return conversationId;
  },
});

// Get all conversations for a user
export const getUserConversations = query({
  args: {
    userId: v.id("users"),
  },
  handler: async (ctx, args) => {
    const conversations = await ctx.db
      .query("conversations")
      .filter((q) =>
        q.or(
          q.eq(q.field("sellerId"), args.userId),
          q.eq(q.field("buyerId"), args.userId)
        )
      )
      .order("desc")
      .collect();

    // Get additional info for each conversation
    const conversationsWithInfo = await Promise.all(
      conversations.map(async (conversation) => {
        // Get the other participant
        const otherUserId = conversation.sellerId === args.userId
          ? conversation.buyerId
          : conversation.sellerId;
        const otherUser = await ctx.db.get(otherUserId);

        // Get unread count
        const unreadMessages = await ctx.db
          .query("messages")
          .withIndex("by_conversation_unread", (q) =>
            q.eq("conversationId", conversation._id).eq("isRead", false)
          )
          .filter((q) => q.neq(q.field("senderId"), args.userId))
          .collect();

        return {
          ...conversation,
          otherUser,
          unreadCount: unreadMessages.length,
          isSeller: conversation.sellerId === args.userId,
        };
      })
    );

    return conversationsWithInfo;
  },
});

// Get a single conversation with details
export const getConversation = query({
  args: {
    conversationId: v.id("conversations"),
  },
  handler: async (ctx, args) => {
    const conversation = await ctx.db.get(args.conversationId);
    if (!conversation) return null;

    const seller = await ctx.db.get(conversation.sellerId);
    const buyer = await ctx.db.get(conversation.buyerId);

    return {
      ...conversation,
      seller,
      buyer,
    };
  },
});

// Update conversation status
export const updateConversationStatus = mutation({
  args: {
    conversationId: v.id("conversations"),
    status: v.union(v.literal("active"), v.literal("archived"), v.literal("completed")),
  },
  handler: async (ctx, args) => {
    await ctx.db.patch(args.conversationId, {
      status: args.status,
    });

    // Add system message about status change
    const statusMessages: Record<string, string> = {
      archived: "Conversation archived",
      completed: "Transaction completed",
      active: "Conversation reactivated",
    };

    await ctx.db.insert("messages", {
      conversationId: args.conversationId,
      senderId: args.conversationId as Id<"users">, // System message
      content: statusMessages[args.status],
      type: "system",
      metadata: {
        systemType: `status_${args.status}`,
      },
      isRead: false,
      createdAt: Date.now(),
    });
  },
});

// Search conversations
export const searchConversations = query({
  args: {
    userId: v.id("users"),
    searchTerm: v.string(),
  },
  handler: async (ctx, args) => {
    const conversations = await ctx.db
      .query("conversations")
      .filter((q) =>
        q.or(
          q.eq(q.field("sellerId"), args.userId),
          q.eq(q.field("buyerId"), args.userId)
        )
      )
      .collect();

    // Filter by search term (item title or last message)
    const filtered = conversations.filter((conv) => {
      const searchLower = args.searchTerm.toLowerCase();
      return (
        conv.itemTitle.toLowerCase().includes(searchLower) ||
        (conv.lastMessage && conv.lastMessage.toLowerCase().includes(searchLower))
      );
    });

    // Get additional info for filtered conversations
    const conversationsWithInfo = await Promise.all(
      filtered.map(async (conversation) => {
        const otherUserId = conversation.sellerId === args.userId
          ? conversation.buyerId
          : conversation.sellerId;
        const otherUser = await ctx.db.get(otherUserId);

        const unreadMessages = await ctx.db
          .query("messages")
          .withIndex("by_conversation_unread", (q) =>
            q.eq("conversationId", conversation._id).eq("isRead", false)
          )
          .filter((q) => q.neq(q.field("senderId"), args.userId))
          .collect();

        return {
          ...conversation,
          otherUser,
          unreadCount: unreadMessages.length,
          isSeller: conversation.sellerId === args.userId,
        };
      })
    );

    return conversationsWithInfo;
  },
});