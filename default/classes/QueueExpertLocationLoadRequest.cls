/**
 * @description Request wrapper for loading queue expert locations.
 */
public class QueueExpertLocationLoadRequest {
    /**
     * @description Selected location identifier.
     */
    public String locationId;

    /**
     * @description Selected resource or expert identifier.
     */
    public String resourceId;

    /**
     * @description Selected service identifier.
     */
    public String serviceId;

    /**
     * @description Category filter for the request.
     */
    public String category;
}