import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  users: defineTable({
    clerkId: v.string(),
    name: v.string(),
    email: v.string(),
    avatar: v.optional(v.string()),
    createdAt: v.number(),
    lastSeen: v.number(),
  })
    .index("by_clerk_id", ["clerkId"])
    .index("by_email", ["email"]),

  conversations: defineTable({
    participants: v.array(v.id("users")),
    itemId: v.string(), // Reference to the item being discussed
    itemTitle: v.string(),
    itemPrice: v.number(),
    itemImage: v.optional(v.string()),
    sellerId: v.id("users"),
    buyerId: v.id("users"),
    lastMessage: v.optional(v.string()),
    lastMessageTime: v.optional(v.number()),
    createdAt: v.number(),
    status: v.union(v.literal("active"), v.literal("archived"), v.literal("completed")),
  })
    .index("by_participants", ["participants"])
    .index("by_seller", ["sellerId"])
    .index("by_buyer", ["buyerId"])
    .index("by_item", ["itemId"]),

  messages: defineTable({
    conversationId: v.id("conversations"),
    senderId: v.id("users"),
    content: v.string(),
    type: v.union(
      v.literal("text"),
      v.literal("image"),
      v.literal("offer"),
      v.literal("system")
    ),
    metadata: v.optional(
      v.object({
        offerAmount: v.optional(v.number()),
        imageUrl: v.optional(v.string()),
        systemType: v.optional(v.string()),
      })
    ),
    isRead: v.boolean(),
    createdAt: v.number(),
    editedAt: v.optional(v.number()),
  })
    .index("by_conversation", ["conversationId", "createdAt"])
    .index("by_sender", ["senderId"])
    .index("by_conversation_unread", ["conversationId", "isRead"]),

  typing: defineTable({
    conversationId: v.id("conversations"),
    userId: v.id("users"),
    timestamp: v.number(),
  })
    .index("by_conversation", ["conversationId"]),
});